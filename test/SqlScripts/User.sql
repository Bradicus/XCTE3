CREATE TABLE [User] (
  [id] VARCHAR(0), 
  [firstName] VARCHAR(255), 
  [lastName] VARCHAR(255), 
  [username] VARCHAR(255), 
  [email] VARCHAR(255)
  , 
  [createdDate] DATETIME, 
  [lastLoginDate] DATETIME, 
  [mailingAddress]TEXT, 
  [physicalAddress]TEXT, 
  [roles] VARCHAR(0), 
  [roleOptions]TEXT, 
  [disabled]TEXT, 
  [theme] VARCHAR(255), 
  [themeOptions]TEXT
  ,
  PRIMARY KEY ([id, ])
) 
