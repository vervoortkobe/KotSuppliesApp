import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { Image } from '../entities/image.entity';
import { CreateUserDto, UpdateUserDto, UserResponseDto } from './dto';

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
    const savedUser = await this.userRepository.save(user);
    const response: UserResponseDto = {
      guid: savedUser.guid,
      username: savedUser.username,
      profileImageGuid: savedUser.profileImageGuid,
    };
    return response;
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
    const savedUser = await this.userRepository.save(user);
    const response: UserResponseDto = {
      guid: savedUser.guid,
      username: savedUser.username,
      profileImageGuid: savedUser.profileImageGuid,
    };
    return response;
  }

  async login(username: string): Promise<UserResponseDto | null> {
    const user = await this.userRepository.findOne({
      where: { username },
      relations: ['accessibleLists', 'notifications'],
    });
    if (!user) return null;
    const response: UserResponseDto = {
      guid: user.guid,
      username: user.username,
      profileImageGuid: user.profileImageGuid,
    };
    return response;
  }

  async findAll(): Promise<UserResponseDto[]> {
    const users = await this.userRepository.find();
    return users.map((user) => ({
      guid: user.guid,
      username: user.username,
      profileImageGuid: user.profileImageGuid,
    }));
  }

  async findOne(guid: string): Promise<UserResponseDto> {
    const user = await this.userRepository.findOne({
      where: { guid },
      relations: [
        'accessibleLists',
        'accessibleLists.users',
        'accessibleLists.categories',
        'accessibleLists.items',
      ],
    });
    if (!user) {
      throw new BadRequestException('User not found');
    }
    return {
      guid: user.guid,
      username: user.username,
      profileImageGuid: user.profileImageGuid,
      accessibleLists: user.accessibleLists,
    };
  }
}
