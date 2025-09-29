import {
  Entity,
  PrimaryColumn,
  Column,
  ManyToMany,
  JoinTable,
  OneToMany,
} from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { User } from './user.entity';
import { Category } from './category.entity';
import { Item } from './item.entity';

@Entity()
export class List {
  @PrimaryColumn('uuid')
  guid: string = uuidv4();

  @Column()
  title: string;

  @Column({ nullable: true })
  description: string;

  @Column({ length: 6 })
  shareCode: string;

  @Column({
    type: 'varchar',
    length: 20,
    nullable: false,
  })
  type: 'image_count' | 'check';

  @ManyToMany(() => User, (user) => user.accessibleLists)
  @JoinTable()
  users: User[];

  @OneToMany(() => Category, (category) => category.list, { cascade: true })
  categories: Category[];

  @OneToMany(() => Item, (item) => item.list, { cascade: true })
  items: Item[];
}
