CREATE TABLE IF NOT EXISTS Action (
	id INTEGER PRIMARY KEY,
	ordering INTEGER,
	status VARCHAR(16),
	statusTimestamp DATE,
	name TEXT NOT NULL,
	flags TEXT
);

CREATE TABLE IF NOT EXISTS ActionFlag ( 
	actionId INTEGER,
	flag VAHRCHAR(16),
	PRIMARY KEY(flag,actionId)
);