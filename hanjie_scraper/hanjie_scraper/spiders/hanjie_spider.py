
from scrapy import Spider, Request
from hanjie_scraper.items import HanjieScraperItem
from scrapy_splash import SplashRequest


class HanjieScraper(Spider):
	name = 'hanjie_scraper'
	allowed_urls = ['http://www.nonograms.org/nonograms']
	start_urls = ['http://www.nonograms.org/nonograms']


	# find all pages
	def parse(self, response):
		# List comprehension to construct all the urls
		page_urls = ['http://www.nonograms.org/nonograms/p/'+ str(i) for i in range(1,328)]

		# Yield the links to each page on the website
		for url in page_urls:
			yield Request(url=url, callback=self.parse_pages)

	# Per page parse
	def parse_pages(self,response):
		# Get links of each puzzle on the page
		puzzle_links = response.xpath('//a[@class = "nonogram_title"]/@href').extract()
		# yield links to each puzzle's page
		for puzzle in puzzle_links:
			yield SplashRequest(puzzle, callback=self.parse_puzzles, args = {"wait":2})

	# Per puzzle parse
	def parse_puzzles(self,response):
		# Get puzzle number for reference
		number = response.xpath('/html/head/title/text()').extract_first()[20:]
		# Title of just the puzzle without extra text from "View Answer <<TITLE>>"
		title = response.xpath('//*[@id="nonogram_answer"]/@title').extract_first()[13:-1]
		# Get size
		sizeText = response.xpath('//div[@class = "content"]/table//tr/td[1]/text()').extract_first()
		# make size into list and assign each dimension to variable
		size = sizeText[6:].split('x')
		sizeRow = size[0]
		sizeCol = size[1]

		# Need to implement splash to get around JS to get the following fields
		rowClues = response.xpath('//*[@class="nmtt"]/table/tbody//tr//td//div/text()').extract()

		colClues = response.xpath('//*[@class="nmtl"]/table/tbody//tr//td//div/text()').extract()

		# puzzle difficulty, helpful to organize which ones we should start with for neural net
		difficulty = response.xpath('//div[@class="content"]/table//tr/td[3]/img/@alt').extract_first()
		# puzzle solution link to image to be used for supervised learning
		solution = response.xpath('//*[@id = "nonogram_answer"]/@href').extract_first()


		item = HanjieScraperItem()
		item['number'] = number
		item['title'] = title
		item['sizeRow'] = sizeRow
		item['sizeCol'] = sizeCol
		item['rowClues'] = rowClues
		item['colClues'] = colClues
		item['difficulty'] = difficulty
		item['solution'] = solution

		yield item
