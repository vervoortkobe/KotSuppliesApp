import {
  Controller,
  Post,
  Get,
  Param,
  Res,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
  HttpCode,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response } from 'express';
import { ImagesService } from './images.service';

@Controller('images')
export class ImagesController {
  constructor(private readonly imagesService: ImagesService) {}

  @Post('upload')
  @HttpCode(201)
  @UseInterceptors(FileInterceptor('file'))
  async upload(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('No file uploaded');
    }
    return this.imagesService.upload(file);
  }

  @Get(':guid')
  @HttpCode(200)
  async findOne(@Param('guid') guid: string, @Res() res: Response) {
    const image = await this.imagesService.findOne(guid);
    if (!image) {
      throw new BadRequestException('Image not found');
    }
    res.contentType(image.mimeType);
    res.send(image.data);
  }
}
