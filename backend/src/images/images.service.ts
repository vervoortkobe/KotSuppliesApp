import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Image } from '../entities/image.entity';

@Injectable()
export class ImagesService {
  constructor(
    @InjectRepository(Image) private imageRepository: Repository<Image>,
  ) {}

  async upload(file: Express.Multer.File) {
    const image = new Image();
    image.data = file.buffer;
    image.mimeType = file.mimetype;
    return this.imageRepository.save(image);
  }

  async findOne(guid: string) {
    return this.imageRepository.findOneBy({ guid });
  }
}
