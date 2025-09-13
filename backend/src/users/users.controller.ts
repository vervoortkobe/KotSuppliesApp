import {
  Controller,
  Post,
  Body,
  Put,
  Param,
  Get,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { UsersService } from './users.service';
import { CreateUserDto, LoginUserDto, UpdateUserDto } from './dto';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('create')
  @UseInterceptors(FileInterceptor('profileImage'))
  async create(
    @Body() createUserDto: CreateUserDto,
    @UploadedFile() file?: Express.Multer.File,
  ) {
    return this.usersService.create(createUserDto, file);
  }

  @Put(':guid')
  @UseInterceptors(FileInterceptor('profileImage'))
  async update(
    @Param('guid') guid: string,
    @Body() updateUserDto: UpdateUserDto,
    @UploadedFile() file?: Express.Multer.File,
  ) {
    return this.usersService.update(guid, updateUserDto, file);
  }

  @Post('login')
  async login(@Body() loginUserDto: LoginUserDto) {
    const user = await this.usersService.login(loginUserDto.username);
    if (!user) {
      throw new BadRequestException('User does not exist');
    }
    return user;
  }
}
