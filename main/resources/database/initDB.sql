CREATE TABLE IF NOT EXISTS modems (
  id          BIGINT      NOT NULL PRIMARY KEY,
  street      VARCHAR(45) NULL,
  houseNumber VARCHAR     NULL,
  linkToMAC   VARCHAR     NULL
);

CREATE TABLE IF NOT EXISTS measurements (
  id                 BIGINT   NOT NULL PRIMARY KEY,
  dateTime           DATETIME NULL,
  usTXPower          FLOAT    NULL,
  usRXPower          FLOAT    NULL,
  usSNR              FLOAT    NULL,
  dsRxPower          FLOAT    NULL,
  dsSNR              FLOAT    NULL,
  microReflex        FLOAT    NULL,
  linkToCurrentState VARCHAR  NULL,
  linkToInfoPage     VARCHAR  NULL
);


CREATE TABLE IF NOT EXISTS locations (
  id                   BIGINT NOT NULL PRIMARY KEY,
  entranceNumber       INT    NULL,
  floorNumber          INT    NULL,
  interFloorLineNumber INT    NULL,
  apartment            VARCHAR
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


CREATE TABLE IF NOT EXISTS modem_mesurements (
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
