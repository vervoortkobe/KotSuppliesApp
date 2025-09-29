import {
  Controller,
  Post,
  Body,
  Get,
  Param,
  Put,
  Delete,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
  HttpCode,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ItemsService } from './items.service';
import { CreateItemDto, UpdateItemDto, BulkItemDto } from './dto';

@Controller('items')
export class ItemsController {
  constructor(private readonly itemsService: ItemsService) {}

  @Post(':listGuid')
  @HttpCode(201)
  @UseInterceptors(FileInterceptor('image'))
  async create(
    @Param('listGuid') listGuid: string,
    @Body() createItemDto: CreateItemDto,
    @UploadedFile() file?: Express.Multer.File,
  ) {
    return this.itemsService.create(listGuid, createItemDto, file);
  }

  @Get(':listGuid/:itemGuid')
  @HttpCode(200)
  async findOne(
    @Param('listGuid') listGuid: string,
    @Param('itemGuid') itemGuid: string,
  ) {
    const item = await this.itemsService.findOne(listGuid, itemGuid);
    if (!item) {
      throw new BadRequestException('Item not found');
    }
    return item;
  }

  @Put(':listGuid/:itemGuid')
  @HttpCode(200)
  @UseInterceptors(FileInterceptor('image'))
  async update(
    @Param('listGuid') listGuid: string,
    @Param('itemGuid') itemGuid: string,
    @Body() updateItemDto: UpdateItemDto,
    @UploadedFile() file?: Express.Multer.File,
  ) {
    return this.itemsService.update(listGuid, itemGuid, updateItemDto, file);
  }

  @Delete(':listGuid/:itemGuid')
  @HttpCode(200)
  async delete(
    @Param('listGuid') listGuid: string,
    @Param('itemGuid') itemGuid: string,
  ) {
    return this.itemsService.delete(listGuid, itemGuid);
  }

  @Post(':listGuid/bulk')
  @HttpCode(200)
  async bulkOperation(
    @Param('listGuid') listGuid: string,
    @Body() bulkItemDto: BulkItemDto,
  ) {
    return this.itemsService.bulkOperation(listGuid, bulkItemDto);
  }
}
