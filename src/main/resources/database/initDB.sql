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
  apartment            VARCHAR NULL
);



CREATE TABLE IF NOT EXISTS modems_measurements (
  modemId BIGINT NULL,
  measurementsId     BIGINT NULL,

  FOREIGN KEY (modemId)
  REFERENCES modems (id)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION,

  FOREIGN KEY (measurementsId)
  REFERENCES measurements (id)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
);


CREATE TABLE IF NOT EXISTS modems_location (
  modemid   BIGINT NOT NULL,
  locationid BIGINT NULL,

  FOREIGN KEY (modemid)

  REFERENCES modems (id)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION,

  FOREIGN KEY (locationid)
  REFERENCES locations (id)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
);
