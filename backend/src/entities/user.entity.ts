import { Entity, PrimaryColumn, Column, OneToMany } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { List } from './list.entity';
import { Notification } from './notification.entity';

@Entity()
export class User {
  @PrimaryColumn('uuid')
  guid: string = uuidv4();

  @Column({ unique: true })
  username: string;

  @Column({ nullable: true })
  profileImageGuid: string;

  @OneToMany(() => List, (list) => list.users)
  accessibleLists: List[];

  @OneToMany(() => Notification, (notification) => notification.user)
  notifications: Notification[];
}
