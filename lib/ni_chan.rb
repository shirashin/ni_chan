# ni_chan
# * search 2ch threads
# * get 2ch posts from thread
require "nokogiri"
require 'open-uri'
require 'kconv'
require 'json'

module NiChan
  SEARCH_BASE_URL = "https://ff2ch.syoboi.jp/?q=%s"
  SEARCH_THREAD_XPATH = '/html/body/ul/li'
  THREAD_URL_XPATH    = './*[@href][1]'
  THREAD_TITLE_XPATH  = './*[@href][1]'
  COUNT_XPATH         = './*[@class=\'count\']'
  BORD_XPATH          = "./*[@class='board']"
  BORD_URL_XPATH      = "./*[@href][2]"
  SPEED_XPATH         = "./*[@class='speed2']"
  TIME_XPATH          = "./*[@class='time']"

  # keyword
  class Search
    def initialize(keyword)
      @keyword = keyword
    end

    def get_threads
      url = SEARCH_BASE_URL % URI.escape(@keyword)
      html = open(url) do |f|
        f.read
      end
      doc                 = Nokogiri::HTML.parse(html.toutf8, nil, "utf-8")
      results             = doc.xpath(SEARCH_THREAD_XPATH)
      return [] if results.empty? # no thread 
      # return array
      results.map do |r|
        url = r.xpath(THREAD_URL_XPATH).first.attributes["href"].value
         {
          url: url,
          title: r.xpath(THREAD_TITLE_XPATH).text.strip,
          id: url.split("/").last,
          count: r.xpath(COUNT_XPATH).text.match(/\d+/)[0],
          bord: r.xpath(BORD_XPATH).text,
          bord_url: r.xpath(BORD_URL_XPATH).first.attributes["href"].value,
          speed: r.xpath(SPEED_XPATH).text,
          time: Time.parse(r.xpath(TIME_XPATH).text),
        }
      end
    end
  end

  # get thread
  class Thread
    class ThreadIsStoped < StandardError; end

    POSTS_XPATH = "//div[@class='post']"
    ID_XPATH = "./@id"
    USER_ID_XPATH = "./@data-userid"
    DATA_ID_XPATH = "./@data-id"
    NAME_XPATH = "./*[@class='name']"
    MESSAGE_XPATH = "./*[@class='message']"
    DATE_XPATH    = ".//div[@class='date']"
    STOPED_XPATH  = '//div[@class="stoplight stopred stopdone"]'
    
		attr_reader :url
    def initialize(url)
      @url = url
    end

    def read(start_id=1)
      html = open(@url) { |f| f.read }
      doc = Nokogiri::HTML.parse(html.toutf8, nil, "utf-8")
      posts = []

      # stoped thread
      if !doc.xpath(STOPED_XPATH).empty?
        raise ThreadIsStoped, doc.xpath(STOPED_XPATH)[0].text
      end
      doc.xpath(POSTS_XPATH).each do |post|
        id = post.xpath(ID_XPATH).text.to_i
        if id >= start_id
          message = post.xpath(MESSAGE_XPATH)
          message.search('br').each{|br| br.replace("\n") }
          posts << {
            id: id,
            user_id: post.xpath(USER_ID_XPATH).text[3..-1],
            data_id: post.xpath(DATA_ID_XPATH).text,
            name: post.xpath(NAME_XPATH).text,
            date: Time.parse(post.xpath(DATE_XPATH).text.sub(/ ID:.*/, "")),
            message: message.text
          }
        end
      end
      posts
    end
  end
end
