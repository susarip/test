import scrapy
from design_scraper.items import DesignScraperItem

class WayfairSofas(scrapy.Spider):
    name = "wayfairsofas"

    def start_requests(self):
        urls = ['https://www.wayfair.com/shop-by-style/cat/modern-sofas-sectionals-c1867932.html?curpage=' + str(i) for i in range (1,13)]
        for url in urls:
            yield scrapy.Request(url=url, callback=self.parse)

    def parse(self,response):
            productName = response.xpath('//*[@id="sbprodgrid"]/div[1]/div[3]/div/div/a/div[2]/div[2]/h2/text()').extract_first()
            productManufacturer = response.xpath('//*[@id="sbprodgrid"]/div[1]/div[3]/div/div/a/div[2]/div[2]/p/text()').extract_first()
            price = response.xpath('//*[@id="sbprodgrid"]/div[1]/div[3]/div/div/a/div[2]/div[3]/span[1]/span/text()').extract_first()
            starRating = response.xpath('//*[@id="sbprodgrid"]/div[1]/div[2]/div/div/a/div[2]/div[3]/span/text()').extract_first()
            reviewNumber = response.xpath('//*[@id="sbprodgrid"]/div[1]/div[2]/div/div/a/div[2]/div[4]/div/p/text()').extract_first()

            item = DesignScraperItem()
            item['productName'] = productName
            item['productManufacturer'] = productManufacturer
            item['price'] = price
            item['starRating'] = starRating
            item['reviewNumber'] = reviewNumber
