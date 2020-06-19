

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_avocat', 'Avocat', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_avocat', 'Avocat', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_avocat', 'Avocat', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('avocat', 'Avocat')
;
INSERT INTO `jobs` (name, label) VALUES
	('offavocat', 'Avocat')
;


INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('avocat',0,'conseiler','Conseiller',12,'{}','{}'),
	('avocat',1,'novice','Apprenti',24,'{}','{}'),
	('avocat',2,'avocat','Avocat',36,'{}','{}'),
	('avocat',3,'proc','Procureur',48,'{}','{}'),
	('avocat',4,'boss','Juge',0,'{}','{}')
;
INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('offavocat',0,'conseiler','Conges',0,'{}','{}'),
	('offavocat',1,'novice','Conges',0,'{}','{}'),
	('offavocat',2,'avocat','Conges',0,'{}','{}'),
	('offavocat',3,'proc','Conges',0,'{}','{}'),
	('offavocat',4,'boss','Conges',0,'{}','{}')
;