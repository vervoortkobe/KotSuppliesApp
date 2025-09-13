import { Entity, PrimaryColumn, Column } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';

@Entity()
export class Image {
  @PrimaryColumn('uuid')
  guid: string = uuidv4();

  @Column({ type: 'blob' })
  data: Buffer;

  @Column()
  mimeType: string;
}
