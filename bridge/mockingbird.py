#!/usr/bin/env python3

import websockets
import argparse
import asyncio
import queue
import json
import threading
import typing
import traceback
import sys
import struct
import time
from threading import Timer
from mitmproxy import ctx
from mitmproxy import http

WEBSOCKET_PATH = "ws://localhost:5000/api/stream"

def debug(text):
    print(">> [MockingBirdAdapter]: " + text)

class MockingBirdAdapter:

    def __init__(self):
        self.queue = queue.Queue(maxsize = 10)
        self.intercept_paths = frozenset([])
        self.finished = False
        self.isConnected = False
        self.wasStarted = False

    def websocket_thread(self):
        self.worker_event_loop = asyncio.new_event_loop()
        self.worker_event_loop.run_until_complete(self.websocket_loop())

    def load(self, loader):
        loader.add_option("intercept", str, "", "A list of HTTP paths, delimited by a comma. E.g.: /foo,/bar")
        return

    def configure(self, updates):
        if "intercept" in updates:
            self.intercept_paths = frozenset(ctx.options.intercept.split(","))
            debug("Intercept paths: " + self.intercept_paths)
        return

    def is_text_response(self, headers):
        if 'content-type' in headers:
            ct = headers['content-type'].lower()
            return 'application' in ct or 'text' in ct or ct.strip() == ""
        return True

    def decode_body(self, url, content):
        
        body = ""
        parsed = True

        if len(content) > 0:
            try:
                body = content.decode("utf-8")
            except UnicodeDecodeError:        
                parsed = False    
                debug("CONTENT EXCEPTION: " + str(url))

        return body, parsed

    def convert_body_to_bytes(self, body):
        if body is None:
            return bytes()
        else:
            return body

    def convert_headers_to_bytes(self, header_entry):
        return [bytes(header_entry[0], "utf8"), bytes(header_entry[1], "utf8")]

    def cleanup_client(self, flow):
        debug("Cleaning client")

        try:
            if flow is not None:
                flow.client_conn.finish()
            else: 
                debug("Flow was already killed")
        except:
            debug("Invalid flow to cleanup")

    def start_cleanup(self, flow):
        debug("Starting cleanup check")

        try:
            self.timer.cancel()
        except:
            debug("Not yet initialized to cancel")

        self.timer = Timer(10, self.cleanup_client, [flow]).start()
    
    def send_websocket_message(self, metadata, data1, data2):

        msg = json.dumps(metadata)

        obj = {
            'lock': threading.Condition(),
            'msg': msg,
            'response': None
        }

        obj['lock'].acquire()
        self.queue.put(obj)

        debug("Start waiting sending msg")
        obj['lock'].wait(timeout=2)
        debug("Waiting finished!")

        new_response = obj['response']

        if new_response is None:
            debug("Without response!")
            return None

        try:
            return json.loads(new_response)
        except:
            debug("Response JSON Exception for message: " + new_response)

        return ""

    def responseheaders(self, flow):
        flow.response.stream = flow.request.path not in self.intercept_paths and not self.is_text_response(flow.response.headers)

    def response(self, flow):

        if self.wasStarted == False:
            debug("Initializing websocket")
            threading.Thread(target=self.websocket_thread).start()
            self.wasStarted = True

        self.start_cleanup(flow)

        if self.isConnected == False:
            debug("Not connected on Websocket")
            return

        if flow.response.stream:
            return

        request = flow.request
        response = flow.response
        
        requestBody, parsed = self.decode_body(request.url, request.content)        
        if parsed == False:
            return

        responseBody, parsed = self.decode_body(request.url, response.content)
        if parsed == False:
            return

        message_response = self.send_websocket_message({
            'request': {
                'method': request.method,
                'url': request.url,
                'headers': list(request.headers.items(True)),
                'body': requestBody
            },
            'response': {
                'status_code': response.status_code,
                'headers': list(response.headers.items(True)),
                'body': responseBody
            }
        }, self.convert_body_to_bytes(request.content), self.convert_body_to_bytes(response.content))

        if message_response is None:
            debug("message: NONE")
            return


        if message_response.get('response') is None:
            debug("message RESPONSE: NONE")
            debug("message URL: " + str(request.url))
            return

        data_response = message_response['response']
        data_response_status = int(data_response['status_code'])
        data_response_headers = data_response['headers']
        data_response_body = data_response['body']

        flow.response = http.HTTPResponse.make(
            data_response_status,
            data_response_body,
            map(self.convert_headers_to_bytes, data_response_headers)
        )

        return

    def done(self):

        debug("Done")

        self.finished = True
        self.queue.put(None)
        return

    async def websocket_loop(self):
        while not self.finished:
            try:
                async with websockets.connect(WEBSOCKET_PATH, max_size = None) as websocket:
                    while True:
                        
                        await websocket.ping()
                        self.isConnected = True

                        try:
                            obj = self.queue.get(timeout=2)

                            try:
                                debug("Sending message through websocket")

                                obj['lock'].acquire()
                                await websocket.send(obj['msg'])
                                obj['response'] = await websocket.recv()

                                debug("Received message through websocket")
                                
                            finally:

                                debug("Notify thread")

                                obj['lock'].notify()
                                obj['lock'].release()
                                
                        except queue.Empty:
                            pass

            except websockets.exceptions.ConnectionClosed:
                self.isConnected = False
                pass
            except BrokenPipeError:
                self.isConnected = False
                pass
            except IOError:
                self.isConnected = False
                pass
            except:
                self.isConnected = False
                debug("Unexpected error:", sys.exc_info())
                traceback.print_exc(file=sys.stdout)
