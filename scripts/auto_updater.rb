#!/usr/bin/env ruby

require 'date'
require 'rexml/document'

def sparkle do

	version = ''
	xml_file = '../.updates/appcast.xml'
	app_zip = ''
	release_notes = ''
	download_url = ''

	doc = REXML::Document.new(File.read(xml_file))
    channel = doc.elements['/rss/channel']

    # Add a new item to the Appcast feed
    item = channel.add_element('item')
    item.add_element("title").add_text("Version #{version}")
    item.add_element("sparkle:minimumSystemVersion").add_text(DEPLOYMENT_TARGET)
    item.add_element("sparkle:releaseNotesLink").add_text(release_notes)
    item.add_element("pubDate").add_text(DateTime.now.strftime("%a, %d %h %Y %H:%M:%S %z"))

    enclosure = item.add_element("enclosure")
    enclosure.attributes["type"] = "application/octet-stream"
    enclosure.attributes["sparkle:version"] = version
    enclosure.attributes["length"] = File.size(app_zip)
    enclosure.attributes["url"] = download_url

    # Write it out
    formatter = REXML::Formatters::Pretty.new(2)
    formatter.compact = true
    new_xml = ""
    formatter.write(doc, new_xml)
    File.open(xml_file, 'w') { |file| file.write new_xml }

end
