
from scrapy import Spider, Request
from hanjie_scraper.items import HanjieScraperItem
from scrapy.spiders import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor


class HanjieScraper(Spider):
	name = 'hanjie_scraper'
	allowed_urls = ['http://www.nonograms.org/nonograms']
	start_url = ['http://www.nonograms.org/nonograms']



	def parse(self, response):
		# List comprehension to construct all the urls
		page_urls = ['http://www.nonograms.org/nonograms/p/'+ str(i) for i in range(1,3)]

		# Yield the requests to different search result urls,
		# using parse_result_page function to parse the response.
		for url in result_urls[:1]:
			yield Request(url=url, callback=self.parse_pages)

	def parse_pages(self,response):
		item_links = response.xpath('//a[@class = "nonogram_title"]/@href').extract()
		for a in item_links:
			yield Request(a, callback=self.parse_puzzles)

	def parse_puzzles(self,response):
		title = response.xpath('/html/head/title/text()').extract_first()[37:-2]
		sizeText = response.xpath('//div[@class = "content"]/table//tr/td[1]/text()').extract()
		size = sizeText[6:].split('x')
		sizeRow = size[0]
		sizeCol = size[1]
		#rowClues = response.xpath('').extract_first()
		#colClues = response.xpath('').extract_first()
		difficulty = response.xpath('//div[@class="content"]/table//tr/td[3]/img/@alt').extract_first()
		solution = response.xpath('//div[@class = "content"]/a[@class = "lightbox"]/@href').extract_first()


		item = ZocdocItem()
		item['title'] = title
		item['sizeRow'] = sizeRow
		item['sizeCol'] = sizeCol
		item['rowClues'] = 0 #rowClues
		item['colClues'] = 0 #colClues
		item['difficulty'] = difficulty
		item['solution'] = solution

		yield item