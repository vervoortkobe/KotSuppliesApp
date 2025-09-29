import { IsString, IsEnum, IsOptional, IsNotEmpty } from 'class-validator';

export class CreateListDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsEnum(['image_count', 'check'], {
    message: 'type must be either image_count or check',
  })
  @IsNotEmpty()
  type: 'image_count' | 'check';

  @IsString()
  @IsNotEmpty()
  creatorGuid: string;
}

export class UpdateListDto {
  @IsString()
  @IsOptional()
  title?: string;

  @IsString()
  @IsOptional()
  description?: string;
}
