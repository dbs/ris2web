DROP SCHEMA zotero CASCADE;
CREATE SCHEMA zotero;
SET search_path TO zotero;
CREATE TABLE itemTypes (
    itemTypeID INTEGER PRIMARY KEY,
    typeName TEXT,
    templateItemTypeID INT,
    display INT DEFAULT 1 -- 0 == hide, 1 == display, 2 == primary
);
CREATE TABLE itemTypesCombined (
    itemTypeID INT NOT NULL,
    typeName TEXT NOT NULL,
    display INT DEFAULT 1 NOT NULL,
    custom INT NOT NULL,
    PRIMARY KEY (itemTypeID)
);
CREATE TABLE fieldFormats (
    fieldFormatID INTEGER PRIMARY KEY,
    regex TEXT,
    isInteger INT
);
CREATE TABLE fields (
    fieldID INTEGER PRIMARY KEY,
    fieldName TEXT,
    fieldFormatID INT,
    FOREIGN KEY (fieldFormatID) REFERENCES fieldFormats(fieldFormatID)
);
CREATE TABLE fieldsCombined (
    fieldID INT NOT NULL,
    fieldName TEXT NOT NULL,
    label TEXT,
    fieldFormatID INT,
    custom INT NOT NULL,
    PRIMARY KEY (fieldID)
);
CREATE TABLE itemTypeFields (
    itemTypeID INT,
    fieldID INT,
    hide INT,
    orderIndex INT,
    PRIMARY KEY (itemTypeID, orderIndex),
    UNIQUE (itemTypeID, fieldID),
    FOREIGN KEY (itemTypeID) REFERENCES itemTypes(itemTypeID),
    FOREIGN KEY (fieldID) REFERENCES fields(fieldID)
);
CREATE TABLE itemTypeFieldsCombined (
    itemTypeID INT NOT NULL,
    fieldID INT NOT NULL,
    hide INT,
    orderIndex INT NOT NULL,
    PRIMARY KEY (itemTypeID, orderIndex),
    UNIQUE (itemTypeID, fieldID)
);
CREATE TABLE baseFieldMappings (
    itemTypeID INT,
    baseFieldID INT,
    fieldID INT,
    PRIMARY KEY (itemTypeID, baseFieldID, fieldID),
    FOREIGN KEY (itemTypeID) REFERENCES itemTypes(itemTypeID),
    FOREIGN KEY (baseFieldID) REFERENCES fields(fieldID),
    FOREIGN KEY (fieldID) REFERENCES fields(fieldID)
);
CREATE TABLE baseFieldMappingsCombined (
    itemTypeID INT,
    baseFieldID INT,
    fieldID INT,
    PRIMARY KEY (itemTypeID, baseFieldID, fieldID)
);
CREATE TABLE charsets (
    charsetID INTEGER PRIMARY KEY,
    charset TEXT UNIQUE
);
CREATE TABLE fileTypes (
    fileTypeID INTEGER PRIMARY KEY,
    fileType TEXT UNIQUE
);
CREATE TABLE fileTypeMimeTypes (
    fileTypeID INT,
    mimeType TEXT,
    PRIMARY KEY (fileTypeID, mimeType),
    FOREIGN KEY (fileTypeID) REFERENCES fileTypes(fileTypeID)
);
CREATE TABLE creatorTypes (
    creatorTypeID INTEGER PRIMARY KEY,
    creatorType TEXT
);
CREATE TABLE itemTypeCreatorTypes (
    itemTypeID INT,
    creatorTypeID INT,
    primaryField INT,
    PRIMARY KEY (itemTypeID, creatorTypeID),
    FOREIGN KEY (itemTypeID) REFERENCES itemTypes(itemTypeID),
    FOREIGN KEY (creatorTypeID) REFERENCES creatorTypes(creatorTypeID)
);
CREATE TABLE syncObjectTypes (
    syncObjectTypeID INTEGER PRIMARY KEY,
    name TEXT
);
CREATE TABLE transactionSets (
    transactionSetID INTEGER PRIMARY KEY,
    event TEXT,
    id INT
);
CREATE TABLE transactions (
    transactionID INTEGER PRIMARY KEY,
    transactionSetID INT,
    context TEXT,
    action TEXT
);
CREATE TABLE transactionLog (
    transactionID INT,
    field TEXT,
    value TEXT,
    PRIMARY KEY (transactionID, field, value),
    FOREIGN KEY (transactionID) REFERENCES transactions(transactionID)
);
CREATE TABLE version (
    schema TEXT PRIMARY KEY,
    version BIGINT NOT NULL
);
CREATE TABLE settings (
    setting TEXT,
    key TEXT,
    value TEXT,
    PRIMARY KEY (setting, key)
);
CREATE TABLE syncedSettings (
    setting TEXT NOT NULL,
    libraryID INT NOT NULL,
    value TEXT NOT NULL,
    version BIGINT NOT NULL DEFAULT 0,
    synced INT NOT NULL DEFAULT 0,
    PRIMARY KEY (setting, libraryID)
);
CREATE TABLE libraries (
    libraryID INTEGER PRIMARY KEY,
    libraryType TEXT NOT NULL
);
CREATE TABLE items (
    itemID INTEGER PRIMARY KEY,
    itemTypeID INT NOT NULL,
    dateAdded TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dateModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    clientDateModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    libraryID INT,
    key TEXT NOT NULL,
    UNIQUE (libraryID, key),
    FOREIGN KEY (libraryID) REFERENCES libraries(libraryID)
);
CREATE TABLE itemDataValues (
    valueID INTEGER PRIMARY KEY,
    value TEXT
);
CREATE TABLE itemData (
    itemID INT,
    fieldID INT,
    valueID INT,
    PRIMARY KEY (itemID, fieldID),
    FOREIGN KEY (itemID) REFERENCES items(itemID),
    FOREIGN KEY (fieldID) REFERENCES fields(fieldID),
    FOREIGN KEY (valueID) REFERENCES itemDataValues(valueID)
);
CREATE TABLE itemNotes (
    itemID INTEGER PRIMARY KEY,
    sourceItemID INT,
    note TEXT,
    title TEXT,
    FOREIGN KEY (itemID) REFERENCES items(itemID),
    FOREIGN KEY (sourceItemID) REFERENCES items(itemID)
);
CREATE TABLE itemAttachments (
    itemID INT PRIMARY KEY,
    sourceItemID INT,
    linkMode INT,
    mimeType TEXT,
    charsetID INT,
    path TEXT,
    originalPath TEXT,
    syncState INT DEFAULT 0,
    storageModTime BIGINT,
    storageHash TEXT,
    FOREIGN KEY (itemID) REFERENCES items(itemID),
    FOREIGN KEY (sourceItemID) REFERENCES items(itemID)
);
CREATE TABLE tags (
    tagID INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    type INT NOT NULL,
    dateAdded TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dateModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    clientDateModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    libraryID INT,
    key TEXT NOT NULL,
    UNIQUE (libraryID, name, type),
    UNIQUE (libraryID, key)
);
CREATE TABLE itemTags (
    itemID INT,
    tagID INT,
    PRIMARY KEY (itemID, tagID),
    FOREIGN KEY (itemID) REFERENCES items(itemID),
    FOREIGN KEY (tagID) REFERENCES tags(tagID)
);
CREATE TABLE itemSeeAlso (
    itemID INT,
    linkedItemID INT,
    PRIMARY KEY (itemID, linkedItemID),
    FOREIGN KEY (itemID) REFERENCES items(itemID),
    FOREIGN KEY (linkedItemID) REFERENCES items(itemID)
);
CREATE TABLE creatorData (
    creatorDataID INTEGER PRIMARY KEY,
    firstName TEXT,
    lastName TEXT,
    shortName TEXT,
    fieldMode INT,
    birthYear INT
);
CREATE TABLE creators (
    creatorID INTEGER PRIMARY KEY,
    creatorDataID INT NOT NULL,
    dateAdded TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dateModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    clientDateModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    libraryID INT,
    key TEXT NOT NULL,
    UNIQUE (libraryID, key),
    FOREIGN KEY (creatorDataID) REFERENCES creatorData(creatorDataID)
);
CREATE TABLE itemCreators (
    itemID INT,
    creatorID INT,
    creatorTypeID INT DEFAULT 1,
    orderIndex INT DEFAULT 0,
    PRIMARY KEY (itemID, creatorID, creatorTypeID, orderIndex),
    FOREIGN KEY (itemID) REFERENCES items(itemID),
    FOREIGN KEY (creatorID) REFERENCES creators(creatorID),
    FOREIGN KEY (creatorTypeID) REFERENCES creatorTypes(creatorTypeID)
);
CREATE TABLE collections (
    collectionID INTEGER PRIMARY KEY,
    collectionName TEXT NOT NULL,
    parentCollectionID INT DEFAULT NULL,
    dateAdded TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dateModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    clientDateModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    libraryID INT,
    key TEXT NOT NULL,
    UNIQUE (libraryID, key) --,
    --FOREIGN KEY (parentCollectionID) REFERENCES collections(collectionID)
);
CREATE TABLE collectionItems (
    collectionID INT,
    itemID INT,
    orderIndex INT DEFAULT 0,
    PRIMARY KEY (collectionID, itemID),
    FOREIGN KEY (collectionID) REFERENCES collections(collectionID),
    FOREIGN KEY (itemID) REFERENCES items(itemID)
);
CREATE TABLE savedSearches (
    savedSearchID INTEGER PRIMARY KEY,
    savedSearchName TEXT NOT NULL,
    dateAdded TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    dateModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    clientDateModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    libraryID INT,
    key TEXT NOT NULL,
    UNIQUE (libraryID, key)
);
CREATE TABLE savedSearchConditions (
    savedSearchID INT,
    searchConditionID INT,
    condition TEXT,
    operator TEXT,
    value TEXT,
    required TEXT,
    PRIMARY KEY (savedSearchID, searchConditionID),
    FOREIGN KEY (savedSearchID) REFERENCES savedSearches(savedSearchID)
);
CREATE TABLE deletedItems (
    itemID INTEGER PRIMARY KEY,
    dateDeleted TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE relations (
    libraryID INT NOT NULL,
    subject TEXT NOT NULL,
    predicate TEXT NOT NULL,
    object TEXT NOT NULL,
    clientDateModified TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (subject, predicate, object)
);
CREATE TABLE users (
    userID INTEGER PRIMARY KEY,
    username TEXT NOT NULL
);
CREATE TABLE groups (
    groupID INTEGER PRIMARY KEY,
    libraryID INT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    editable INT NOT NULL,
    filesEditable INT NOT NULL,
    FOREIGN KEY (libraryID) REFERENCES libraries(libraryID)
);
CREATE TABLE groupItems (
    itemID INTEGER PRIMARY KEY,
    createdByUserID INT NOT NULL,
    lastModifiedByUserID INT NOT NULL,
    FOREIGN KEY (createdByUserID) REFERENCES users(userID),
    FOREIGN KEY (lastModifiedByUserID) REFERENCES users(userID)
);
CREATE TABLE syncDeleteLog (
    syncObjectTypeID INT NOT NULL,
    libraryID INT NOT NULL,
    key TEXT NOT NULL,
    timestamp INT NOT NULL,
    UNIQUE (syncObjectTypeID, libraryID, key),
    FOREIGN KEY (syncObjectTypeID) REFERENCES syncObjectTypes(syncObjectTypeID)
);
CREATE TABLE storageDeleteLog (
    libraryID INT,
    key TEXT NOT NULL,
    timestamp INT NOT NULL,
    PRIMARY KEY (libraryID, key)
);
CREATE TABLE annotations (
    annotationID INTEGER PRIMARY KEY,
    itemID INT,
    parent TEXT,
    textNode INT,
    "offset" INT,
    x INT,
    y INT,
    cols INT,
    "rows" INT,
    "text" TEXT,
    collapsed BOOL,
    dateModified DATE,
    FOREIGN KEY (itemID) REFERENCES itemAttachments(itemID)
);
CREATE TABLE highlights (
    highlightID INTEGER PRIMARY KEY,
    itemID INTEGER,
    startParent TEXT,
    startTextNode INT,
    startOffset INT,
    endParent TEXT,
    endTextNode INT,
    endOffset INT,
    dateModified DATE,
    FOREIGN KEY (itemID) REFERENCES itemAttachments(itemID)
);
CREATE TABLE proxies (
    proxyID INTEGER PRIMARY KEY,
    multiHost INT,
    autoAssociate INT,
    scheme TEXT
);
CREATE TABLE proxyHosts (
    hostID INTEGER PRIMARY KEY,
    proxyID INTEGER,
    hostname TEXT,
    FOREIGN KEY (proxyID) REFERENCES proxies(proxyID)
);
CREATE TABLE customItemTypes (
    customItemTypeID INTEGER PRIMARY KEY,
    typeName TEXT,
    label TEXT,
    display INT DEFAULT 1, -- 0 == hide, 1 == display, 2 == primary
    icon TEXT
);
CREATE TABLE customFields (
    customFieldID INTEGER PRIMARY KEY,
    fieldName TEXT,
    label TEXT
);
CREATE TABLE customItemTypeFields (
    customItemTypeID INT NOT NULL,
    fieldID INT,
    customFieldID INT,
    hide INT NOT NULL,
    orderIndex INT NOT NULL,
    PRIMARY KEY (customItemTypeID, orderIndex),
    FOREIGN KEY (customItemTypeID) REFERENCES customItemTypes(customItemTypeID),
    FOREIGN KEY (fieldID) REFERENCES fields(fieldID),
    FOREIGN KEY (customFieldID) REFERENCES customFields(customFieldID)
);
CREATE TABLE customBaseFieldMappings (
    customItemTypeID INT,
    baseFieldID INT,
    customFieldID INT,
    PRIMARY KEY (customItemTypeID, baseFieldID, customFieldID),
    FOREIGN KEY (customItemTypeID) REFERENCES customItemTypes(customItemTypeID),
    FOREIGN KEY (baseFieldID) REFERENCES fields(fieldID),
    FOREIGN KEY (customFieldID) REFERENCES customFields(customFieldID)
);
CREATE TABLE translatorCache (
	leafName TEXT PRIMARY KEY,
	translatorJSON TEXT,
	code TEXT,
	lastModifiedTime BIGINT
);

CREATE TABLE zoteroDummyTable (id INTEGER PRIMARY KEY);
