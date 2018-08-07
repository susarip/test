# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy
from scrapy import Field

class DesignScraperItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    productName = Field()
    productManufacturer = Field()
    price = Field()
    starRating = Field()
    reviewNumber = Field()
    pass
