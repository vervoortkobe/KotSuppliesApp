import { IsString, IsOptional } from 'class-validator';

export class CreateUserDto {
  @IsString()
  username: string;
}

export class UpdateUserDto {
  @IsString()
  @IsOptional()
  username?: string;
}

export class LoginUserDto {
  @IsString()
  username: string;
}
