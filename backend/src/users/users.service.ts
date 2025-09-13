import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { User } from '../entities/user.entity';
import { Image } from '../entities/image.entity';
import { CreateUserDto, UpdateUserDto } from './dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User) private userRepository: Repository<User>,
    @InjectRepository(Image) private imageRepository: Repository<Image>,
  ) {}

  async create(createUserDto: CreateUserDto, file?: Express.Multer.File) {
    const existingUser = await this.userRepository.findOneBy({
      username: createUserDto.username,
    });
    if (existingUser) {
      throw new BadRequestException('Username already exists');
    }
    const user = new User();
    user.username = createUserDto.username;
    if (file) {
      const image = new Image();
      image.data = file.buffer;
      image.mimeType = file.mimetype;
      const savedImage = await this.imageRepository.save(image);
      user.profileImageGuid = savedImage.guid;
    }
    return this.userRepository.save(user);
  }

  async update(
    guid: string,
    updateUserDto: UpdateUserDto,
    file?: Express.Multer.File,
  ) {
    const user = await this.userRepository.findOneBy({ guid });
    if (!user) {
      throw new BadRequestException('User not found');
    }
    if (updateUserDto.username) {
      const existingUser = await this.userRepository.findOneBy({
        username: updateUserDto.username,
      });
      if (existingUser && existingUser.guid !== guid) {
        throw new BadRequestException('Username already exists');
      }
      user.username = updateUserDto.username;
    }
    if (file) {
      const image = new Image();
      image.data = file.buffer;
      image.mimeType = file.mimetype;
      const savedImage = await this.imageRepository.save(image);
      user.profileImageGuid = savedImage.guid;
    }
    return this.userRepository.save(user);
  }

  async login(username: string) {
    return this.userRepository.findOne({
      where: { username },
      relations: ['accessibleLists', 'notifications'],
    });
  }
}
