import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { MulterModule } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.use(
    MulterModule.register({
      storage: memoryStorage(),
    }),
  );
  await app.listen(3000);
}
bootstrap();
