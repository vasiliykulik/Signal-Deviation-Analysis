CREATE SCHEMA `pmsystem`;

CREATE TABLE IF NOT EXISTS specialities (
  id   BIGINT      NOT NULL PRIMARY KEY,
  name VARCHAR(45) NULL
);

CREATE TABLE IF NOT EXISTS skills (
  id   BIGINT      NOT NULL PRIMARY KEY,
  name VARCHAR(45) NULL
);


CREATE TABLE IF NOT EXISTS developers (
  id                BIGINT      NOT NULL PRIMARY KEY,
  firstName         VARCHAR(45) NULL,
  lastName          VARCHAR(45) NULL,
  age               INT         NULL,
  salary            DECIMAL     NULL,
  yearsOfExperience INT         NULL,
  experience        VARCHAR(45) NULL
);

CREATE TABLE IF NOT EXISTS teams (
  id   BIGINT      NOT NULL PRIMARY KEY,
  name VARCHAR(45) NULL
);

CREATE TABLE IF NOT EXISTS companies (
  id          BIGINT      NOT NULL PRIMARY KEY,
  name        VARCHAR(45) NULL,
  description VARCHAR(45) NULL
);


CREATE TABLE IF NOT EXISTS documents (
  id      BIGINT      NOT NULL PRIMARY KEY,
  name    VARCHAR(45) NULL,
  content VARCHAR(45) NULL
);


CREATE TABLE IF NOT EXISTS projects (
  id          BIGINT      NOT NULL PRIMARY KEY,
  name        VARCHAR(45) NULL,
  description VARCHAR(45) NULL,
  teamId      BIGINT      NULL,

  documentId  BIGINT      NULL,
  CompanyId   BIGINT      NULL,

  FOREIGN KEY (teamId)

  REFERENCES teams (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (documentId)

  REFERENCES documents (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (CompanyId) REFERENCES companies (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS customers (
  id          BIGINT      NOT NULL,
  name        VARCHAR(45) NULL,
  description VARCHAR(45) NULL,
  PRIMARY KEY (`id`)
);


CREATE TABLE IF NOT EXISTS developer_skills (
  developersId BIGINT NULL,
  skillsId     BIGINT NULL,

  FOREIGN KEY (`developersId`)

  REFERENCES developers (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,

  FOREIGN KEY (skillsId)
  REFERENCES skills (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);


CREATE TABLE IF NOT EXISTS developer_specialities (
  developersId   BIGINT NOT NULL,
  specialitiesId BIGINT NULL,

  FOREIGN KEY (developersId)

  REFERENCES developers (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,

  FOREIGN KEY (specialitiesId)
  REFERENCES specialities (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);


CREATE TABLE IF NOT EXISTS team_developers (
  teamId      BIGINT NULL,
  developerId BIGINT NULL,

  FOREIGN KEY (teamId)
  REFERENCES teams (id)

    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  FOREIGN KEY (developerId)

  REFERENCES developers (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS сompany_customers (
  customersId BIGINT NULL,
  CompanyId   BIGINT NULL,

  FOREIGN KEY (customersId)

  REFERENCES customers (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,

  FOREIGN KEY (CompanyId)
  REFERENCES companies (id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);
