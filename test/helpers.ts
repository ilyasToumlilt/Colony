import { NearDB } from './loader';
import Chance from 'chance';
import { config } from './config';

const chance = new Chance();

export const isGuid = (uuid: string) => {
  if (uuid[0] === '{') {
    uuid = uuid.substring(1, uuid.length - 1);
  }
  const regexGuid = /^({){0,1}[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}(}){0,1}$/gi;
  return regexGuid.test(uuid);
};

export const createDummyData = () => {
  return {
    firstName: chance.first(),
    lastName: chance.last(),
    age: chance.age(),
    ssn: chance.ssn(),
    bio: chance.paragraph(),
    // Basics
    bool: chance.bool(),
    character: chance.character(),
    floating: chance.floating(),
    integer: chance.integer(),
    letter: chance.letter(),
    natural: chance.natural(),
    string: chance.string(),
  };
};

export const createDoc = (key: string) => {
  return NearDB.database(config)
    .collection(key + 'Col')
    .doc(key);
};

export const timeout = (ms: number) => {
  return new Promise((resolve) => setTimeout(resolve, ms));
};
