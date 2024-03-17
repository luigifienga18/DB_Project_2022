/*

Per lavorare con la Base Dati è necessario impostare i formati come seguono:

alter session set NLS_DATE_FORMAT='DD/MM/YYYY';
alter session set NLS_TIMESTAMP_FORMAT='DD/MM/YYYY HH24:MI:SS';

E abilitare dbms_output.put_line
set serverout on;

*/


/*TABLE*/
CREATE TABLE Clienti(
		ID_Abbonamento			CHAR(6),
		Data_di_Scadenza_ABB	DATE 		NOT NULL,
		Nome 					VARCHAR(15) NOT NULL,
		Cognome					VARCHAR(20) NOT NULL,
		CF						CHAR(16) 	NOT NULL,
		Data_di_nascita			DATE		NOT NULL,
		Indirizzo				VARCHAR(50) NOT NULL,

		PRIMARY KEY(ID_Abbonamento)
);

CREATE TABLE Prenotazioni(

		Codice_PR				CHAR(6),
		Data_Ora				TIMESTAMP	NOT NULL,
		Abbonamento				CHAR(6) 	NOT NULL,
		Corso					VARCHAR(15) NOT NULL,
		
		PRIMARY KEY(Codice_PR)
);

CREATE TABLE Corsi(
		
		Nome_Corso				VARCHAR(15),
		Istruttore				CHAR(6)		 NOT NULL,
		Descrizione				VARCHAR(100) DEFAULT 'Non ci sono informazioni',
		
		PRIMARY KEY (Nome_Corso)
);

CREATE TABLE Istruttori(

		ID_Istruttore			CHAR(6),
		Nome					VARCHAR(15)	NOT NULL,
		Cognome					VARCHAR(20) NOT NULL,
		Impianto				VARCHAR(30)	NOT NULL,
		
		PRIMARY KEY(ID_Istruttore)

);

CREATE TABLE Impianti(
		
		Nome_impianto			VARCHAR(30),
		Descrizione				VARCHAR(100) DEFAULT 'Non ci sono informazioni',
		
		PRIMARY KEY(Nome_impianto)
);

/*ALTER TABLE FOREIGN KEY*/
ALTER TABLE Prenotazioni ADD CONSTRAINT FK_ABB_PREN FOREIGN KEY (Abbonamento) REFERENCES Clienti(ID_Abbonamento) ON DELETE CASCADE;

ALTER TABLE Prenotazioni ADD CONSTRAINT FK_COR_PREN FOREIGN KEY (Corso) REFERENCES Corsi(Nome_Corso) ON DELETE CASCADE;

ALTER TABLE Corsi ADD CONSTRAINT FK_IST_CORSI FOREIGN KEY (Istruttore) REFERENCES Istruttori(ID_Istruttore) ON DELETE CASCADE;

ALTER TABLE Istruttori ADD CONSTRAINT FK_IMP_ISTR FOREIGN KEY (Impianto) REFERENCES Impianti(Nome_impianto) ON DELETE CASCADE;


/*ALTER TABLE CHECK*/

ALTER TABLE Clienti ADD CONSTRAINT v3 CHECK (Data_di_nascita<Data_di_Scadenza_ABB);

ALTER TABLE Impianti ADD CONSTRAINT ck_nome_impianto CHECK(Nome_Impianto IN('TENNIS','CALCIO','PALESTRA','PISCINA'));



/****** SEQUENCE *********/

CREATE SEQUENCE sequenza_clienti
		INCREMENT BY 1
		START WITH 100001
		MAXVALUE 199999
		NOCYCLE
		NOCACHE;

CREATE SEQUENCE sequenza_prenotazioni
		INCREMENT BY 1
		START WITH 200001
		MAXVALUE 299999
		NOCYCLE
		NOCACHE;

CREATE SEQUENCE sequenza_istruttori
		INCREMENT BY 1
		START WITH 300001
		MAXVALUE 399999
		NOCYCLE
		NOCACHE;


/**********	VIEW **********/

/*op1 Stampa a Schermo le prenotazioni del cliente con ID_Abbonamento=100001*/
CREATE VIEW op1
	AS SELECT Clienti.Nome, Clienti.Cognome, Clienti.ID_Abbonamento, Prenotazioni.Codice_PR AS Num_Prenotazione,to_char(Prenotazioni.Data_Ora,'dd/mm/yyyy') AS Giorno,to_char(Prenotazioni.Data_Ora,'hh24:mi:ss') AS Orario , Prenotazioni.Corso 
	FROM Clienti JOIN Prenotazioni ON (Clienti.ID_Abbonamento=Prenotazioni.Abbonamento and Prenotazioni.abbonamento=100001)
	ORDER BY Giorno,Orario,Clienti.Cognome, Clienti.Nome, Clienti.ID_Abbonamento;
	
/*op2 Stampa a schermo il numero di clienti prenotati per il giorno 27/12/2022 per il corso Attrezzi*/
CREATE VIEW op2
	AS SELECT Corso, COUNT(Abbonamento) AS Num_Clienti, to_date('27/12/2022', 'dd//mm/yyyy') AS Giorno
	FROM Prenotazioni 
	WHERE Corso = 'ATTREZZI' and to_char(Data_Ora, 'dd/mm/yyyy') = '27/12/2022'
	GROUP BY Corso;
	
/*op7 Stampa a schermo i corsi erogati dall' istruttore 300004(Fabio Grosso)*/
CREATE VIEW op7
	AS SELECT Nome_Corso,Descrizione FROM Corsi WHERE Istruttore = 300004;

/*op8 Stampa a video nome,cognome,id_abb,codice_prenotazione,corso e orario per il giorno 27/12/2022 e per il corso Attrezzi*/
CREATE VIEW op8															
	AS SELECT Clienti.Nome, Clienti.Cognome, Clienti.ID_Abbonamento, Prenotazioni.Codice_PR, Prenotazioni.Corso,to_char(Prenotazioni.Data_Ora,'HH24:MI:SS') AS ORARIO
	FROM Clienti JOIN Prenotazioni ON (Clienti.ID_Abbonamento=Prenotazioni.Abbonamento and to_date(to_char(Prenotazioni.Data_Ora,'DD/MM/YYYY'),'DD/MM/YYYY')=to_date('27/12/2022','DD/MM/YYYY') and Prenotazioni.Corso='ATTREZZI')
	ORDER BY Clienti.Cognome, Clienti.Nome, Clienti.ID_Abbonamento;

CREATE VIEW corsi_disponibili
	AS SELECT Nome_corso,Descrizione FROM Corsi;
	
CREATE VIEW impianti_disponib	
	AS SELECT Nome_impianto,Descrizione FROM Impianti;

CREATE VIEW clienti_prenotati
	AS SELECT Clienti.Nome, Clienti.Cognome, Clienti.ID_Abbonamento, Prenotazioni.Codice_PR, Prenotazioni.Corso,to_char(Prenotazioni.Data_Ora,'DD/MM/YYYY HH24:MI:SS') AS DATA
	FROM Clienti JOIN Prenotazioni ON Clienti.ID_Abbonamento=Prenotazioni.Abbonamento 
	ORDER BY Clienti.Cognome, Clienti.Nome, Clienti.ID_Abbonamento;
	
/**********	PROCEDURE/FUNZIONI	**********/


CREATE OR REPLACE FUNCTION Num_Clienti
	RETURN INTEGER
IS
	Risultato INTEGER;
BEGIN
	BEGIN
		SELECT COUNT(*) INTO Risultato FROM CLIENTI;
		RETURN Risultato;
	END;
END Num_Clienti;

/*op1 Stampa a Schermo le prenotazioni di un certo cliente (identificato da ID_Abbonamento)*/

CREATE OR REPLACE PROCEDURE op1 (id_cliente IN Clienti.ID_Abbonamento%TYPE)
IS
CURSOR cursore IS SELECT Codice_PR, to_char(Data_Ora, 'dd/mm/yyyy') as Giorno, to_char(Data_Ora, 'HH24:MI:SS') as Ora, Corso FROM Prenotazioni WHERE Prenotazioni.Abbonamento = id_cliente;
nome Clienti.Nome%TYPE;
cognome Clienti.Cognome%TYPE;
conteggio_pr INTEGER;
conteggio_cl INTEGER;
vr_curs cursore%ROWTYPE;
errore EXCEPTION;
errore2 EXCEPTION;
BEGIN
    BEGIN
    
        SELECT COUNT(ID_Abbonamento) INTO conteggio_cl FROM Clienti WHERE Clienti.ID_Abbonamento = id_cliente;
            IF(conteggio_cl = 0)
            THEN RAISE errore2;
            END IF;
        SELECT Nome INTO nome FROM Clienti WHERE Clienti.Id_Abbonamento = id_cliente;
        SELECT Cognome INTO cognome FROM Clienti WHERE Clienti.Id_Abbonamento = id_cliente;
        SELECT COUNT(Codice_PR) INTO conteggio_pr FROM Prenotazioni WHERE Prenotazioni.Abbonamento = id_cliente;
        IF(conteggio_pr = 0)
        THEN RAISE errore;
        END IF;
        dbms_output.put_line('Ecco le prenotazioni effettuate da ' || Nome || ' ' || cognome || ' : ');
        OPEN cursore;
        LOOP
            FETCH cursore INTO vr_curs;
            EXIT WHEN cursore%NOTFOUND;
            dbms_output.put_line('Codice prenotazione: ' || vr_curs.Codice_PR || ', Data: ' || vr_curs.Giorno || ', Ora: ' || vr_curs.Ora || ', Corso: ' || vr_curs.Corso);
        END LOOP;
        CLOSE cursore;
        
        EXCEPTION 
        WHEN errore THEN RAISE_APPLICATION_ERROR(-20020, 'Non ci sono prenotazioni associate a questo cliente');
        WHEN errore2 THEN RAISE_APPLICATION_ERROR(-20020, 'Non ci sono clienti associati a questo ID');
    END;
END op1;


/*op3 Stampa a schermo quanti istruttori lavorano per un impianto e i nomi di tali istruttori*/

CREATE OR REPLACE PROCEDURE op3
IS
errore EXCEPTION;
impianto Istruttori.impianto%TYPE;
conteggio INTEGER;
nome Istruttori.Nome%TYPE;
cognome Istruttori.Cognome%TYPE;
CURSOR op3_cursor1 IS SELECT Istruttori.impianto, COUNT (Istruttori.impianto) AS Numero_Istruttori_Per_Impianto FROM Istruttori GROUP BY Istruttori.impianto;
CURSOR op3_cursor2 IS SELECT Istruttori.impianto, Istruttori.Nome,Istruttori.Cognome FROM Istruttori ORDER BY Istruttori.Cognome, Istruttori.Nome;
vr_cursor1 op3_cursor1%ROWTYPE;
vr_cursor2 op3_cursor2%ROWTYPE;
BEGIN
	BEGIN
	SELECT COUNT(*) INTO conteggio FROM Istruttori;
		IF(conteggio=0)
		THEN RAISE errore;
		END IF;
	OPEN op3_cursor1;
	dbms_output.put_line('Stampa dei valori: ');
		LOOP
			FETCH op3_cursor1 INTO vr_cursor1;
			EXIT WHEN op3_cursor1%NOTFOUND;
			conteggio:=vr_cursor1.Numero_Istruttori_Per_Impianto;
			impianto:=vr_cursor1.impianto;
			dbms_output.put_line('All " impianto: '||impianto||' afferiscono '||conteggio||' istruttori/e e sono/ed è: ' );
			OPEN op3_cursor2;
				LOOP
					FETCH op3_cursor2 INTO vr_cursor2;
					EXIT WHEN op3_cursor2%NOTFOUND;
					IF(vr_cursor2.impianto=impianto)
					THEN
						nome:=vr_cursor2.nome;
						cognome:=vr_cursor2.cognome;
						dbms_output.put_line(cognome||' '||nome);
					END IF;
				END LOOP;
			CLOSE op3_cursor2;	
		END LOOP;
	CLOSE op3_cursor1;
	EXCEPTION
	WHEN errore THEN RAISE_APPLICATION_ERROR (-20011,'Non ci sono istruttori');
	END;
END op3;


/*op4 Stampare a video il corso con il massimo numero di prenotazioni*/
CREATE OR REPLACE PROCEDURE op4
IS
max_num INTEGER;
soluzione Prenotazioni.Corso%type;
CURSOR cursor_pren IS SELECT Corso FROM Prenotazioni group by Corso HAVING(COUNT(Corso)=max_num);
vr_pren cursor_pren%ROWTYPE;
errore EXCEPTION;
BEGIN
	BEGIN
	SELECT MAX(COUNT(Prenotazioni.Corso)) INTO max_num FROM Prenotazioni group by Corso ;
	dbms_output.put_line('Ecco il/i corso/i con più prenotazioni: ');
		IF(max_num=0)
			THEN RAISE errore;
		END IF;
	OPEN cursor_pren;
			LOOP
				FETCH cursor_pren INTO vr_pren;
				EXIT WHEN cursor_pren%NOTFOUND;
				soluzione:=vr_pren.corso;
				dbms_output.put_line(soluzione|| ' con numero di prenotazioni: '||max_num);
			END LOOP;
    CLOSE cursor_pren;
	EXCEPTION
	WHEN errore THEN RAISE_APPLICATION_ERROR (-20010,'Non ci sono prenotazioni inserite');
	END;
END op4;

/*op5 Verifica la validità di un abbonameno, se valido calcola la sua durata*/

CREATE OR REPLACE PROCEDURE op5 (abbonamento IN Clienti.ID_Abbonamento%TYPE)
IS
giorni INTEGER;
mesi INTEGER;
anni INTEGER;
diff INTEGER;
da DATE;
BEGIN
    BEGIN
    SELECT Data_di_Scadenza_ABB INTO da FROM Clienti WHERE ID_Abbonamento = abbonamento;
    diff:=TO_NUMBER(TO_DATE(da,'dd/mm/yyyy')-TO_DATE(CURRENT_DATE , 'dd/mm/yyyy'));
        IF (diff < 0)
        THEN
            dbms_output.put_line('Abbonamento scaduto');
        ELSIF (diff = 0)
        THEN
            dbms_output.put_line(' Abbonamento scade oggi');
        ELSE
            dbms_output.put_line('Abbonamento valido');
                IF(diff >= 365)
                THEN
                    anni := TRUNC(diff/365, 0);
                    mesi:=  TRUNC((diff -(anni* 365))/31, 0);
                    giorni := (diff - (anni* 365) - (mesi*31));
                    dbms_output.put_line('Abbonamento dura ancora ' || anni || ' anni, ' || mesi || ' mesi e ' || giorni || ' giorni.');
                ELSIF(diff >= 31 and diff < 365)
                THEN
                    mesi:= TRUNC(diff/31, 0);
                    giorni := diff -(mesi*31);
                    dbms_output.put_line('Abbonamento dura ancora ' || mesi || ' mesi e ' || giorni || ' giorni.');
                ELSE
                    giorni := diff;
                    dbms_output.put_line('Abbonamento dura ancora ' || giorni || ' giorni.');
                END IF;
        END IF;
    END;
END op5;


/*Op6 Procedure che verifica se ci sono prenotazioni vecchie e le elimina*/

CREATE OR REPLACE PROCEDURE contr_pren_old
IS
CURSOR cur_pren IS SELECT Codice_PR,Data_Ora FROM Prenotazioni;
vr_cur_pren cur_pren%ROWTYPE;
BEGIN
	BEGIN
	OPEN cur_pren;
		LOOP
			FETCH cur_pren INTO vr_cur_pren;
			EXIT WHEN cur_pren%NOTFOUND;
				IF(CURRENT_DATE>vr_cur_pren.Data_Ora)
					THEN DELETE FROM Prenotazioni WHERE Codice_PR=vr_cur_pren.Codice_PR;
					COMMIT;
				END IF;
		END LOOP;
	CLOSE cur_pren;
	END;
END contr_pren_old;


/*Op9 Procedura che cancella la prenotazione associata ad un certo codice */

CREATE OR REPLACE PROCEDURE op9 (prenotazione IN Prenotazioni.Codice_PR%TYPE)
IS
cont INTEGER;
errore EXCEPTION;
BEGIN
    BEGIN
        SELECT COUNT(*) INTO cont FROM Prenotazioni WHERE Codice_PR = prenotazione;
        IF(cont = 0)
        THEN RAISE errore;
        ELSE
            DELETE FROM Prenotazioni WHERE Codice_PR = prenotazione;
            COMMIT;
        END IF;
        EXCEPTION
        WHEN errore THEN raise_application_error(-20013,'Non ci sono prenotazioni associate a questo codice');
    END;
END op9;


/**********	TRIGGER	**********/

/*In tr_controllo_cl c'è il controllo che l'età sia >=18 (v15) e un controllo affinchè la data di scadenza sia maggiore della data corrente(v16)*/

CREATE OR REPLACE TRIGGER tr_controllo_cl
BEFORE INSERT ON Clienti
FOR EACH ROW
DECLARE
errore EXCEPTION;
errore2 EXCEPTION;
BEGIN
	IF(TRUNC((TO_NUMBER(TO_DATE(CURRENT_DATE , 'dd/mm/yyyy')-TO_DATE(:new.Data_di_nascita,'dd/mm/yyyy'))/365),0)<18)
		THEN RAISE errore;
	end if;
	IF(:new.Data_di_Scadenza_ABB<CURRENT_DATE)
		THEN RAISE errore2;
	END IF;
EXCEPTION
WHEN errore THEN raise_application_error(-20001,'Data di nascita non valida: il cliente deve essere maggiorenne');
WHEN errore2 THEN raise_application_error(-20012,'La data di scadenza dell"abbonamento deve essere maggiore del giorno odierno');
END;

/*Dimensionamento Clienti*/
CREATE OR REPLACE TRIGGER tr_controllo_num_cl
BEFORE INSERT ON Clienti
FOR EACH ROW
DECLARE
errore EXCEPTION;
num_max_clienti CONSTANT INTEGER :=100;
BEGIN
	IF (Num_Clienti>=num_max_clienti)
		then raise errore;
	END IF;
EXCEPTION
WHEN errore THEN RAISE_APPLICATION_ERROR (-20002, 'Massimo 100 Clienti');
END;

/*In tr_controllo_pr si effettua il controllo del dimensionamento Prenotazioni (v5), del controllo della fascia oraria prenotazione(v1) e che la data di prenotazione
debba essera più grande della data corrente
 */

CREATE OR REPLACE TRIGGER tr_controllo_pr
BEFORE INSERT ON Prenotazioni
FOR EACH ROW
DECLARE
errore1 EXCEPTION;
errore2 EXCEPTION;
errore3 EXCEPTION;
num_pr_id INTEGER:=0;
BEGIN
		SELECT COUNT(Abbonamento) INTO num_pr_id FROM Prenotazioni WHERE :new.Abbonamento=Abbonamento GROUP BY Abbonamento;
			IF(num_pr_id>=4)
				THEN RAISE errore1;
			END IF;
		if(to_date(to_char(:new.Data_Ora,'HH24:MI:SS'),'HH24:MI:SS') not between to_date('09:00:00', 'HH24:MI:SS') and to_date('19:00:00', 'HH24:MI:SS'))
			THEN RAISE errore2;
		END IF;
		IF(:new.Data_Ora<CURRENT_DATE)
		THEN RAISE errore3;
		END IF;

EXCEPTION
WHEN errore1 THEN RAISE_APPLICATION_ERROR (-20003, 'Massimo 4 prenotazioni per Cliente');
WHEN errore2 THEN RAISE_APPLICATION_ERROR (-20007, 'Le prenotazioni possono essere effettuate solo tra le 9 e le 19');
WHEN errore3 THEN RAISE_APPLICATION_ERROR (-20013, 'La data di prenotazioni deve essere maggiore della data corrente');
WHEN NO_DATA_FOUND THEN num_pr_id:=0;
END;

/*Dimensionamento Corsi*/

CREATE OR REPLACE TRIGGER tr_num_corso
BEFORE INSERT ON Corsi
FOR EACH ROW
DECLARE
errore1 EXCEPTION;
num_co_id INTEGER:=0;
imp Impianti.Nome_impianto%TYPE;
BEGIN
    SELECT Impianto INTO imp FROM Istruttori WHERE ID_Istruttore =:new.Istruttore;
    SELECT COUNT(Corsi.Nome_Corso) INTO num_co_id FROM (Corsi JOIN Istruttori ON Corsi.Istruttore = Istruttori.ID_Istruttore) WHERE Istruttori.Impianto = imp;
            IF(num_co_id>=2)
            THEN RAISE errore1;
            END IF;
EXCEPTION
WHEN errore1 THEN RAISE_APPLICATION_ERROR (-20004, 'Massimo 2 Corsi per Impianto');
WHEN NO_DATA_FOUND THEN num_co_id:=0;
END;

/*Dimensionamento Impianti*/

CREATE OR REPLACE TRIGGER tr_num_impianti
BEFORE INSERT ON Impianti
FOR EACH ROW
DECLARE
num_im INTEGER;
errore EXCEPTION;
num_max CONSTANT INTEGER:=4;
BEGIN
	SELECT COUNT(*) INTO num_im FROM IMPIANTI;
	IF(num_im>=num_max )
	THEN RAISE errore;
	END IF;
EXCEPTION
WHEN errore THEN RAISE_APPLICATION_ERROR (-20005, 'Massimo 4 Impianti');
END;

/*Dimensionamento Istruttori*/

CREATE OR REPLACE TRIGGER tr_num_istruttori
BEFORE INSERT ON Istruttori
FOR EACH ROW
DECLARE
num_is INTEGER;
errore EXCEPTION;
num_max CONSTANT INTEGER:=10;
BEGIN
	SELECT COUNT(*) INTO num_is FROM Istruttori;
	IF(num_is>=num_max)
	THEN RAISE errore;
	END IF;
EXCEPTION
WHEN errore THEN RAISE_APPLICATION_ERROR (-20006, 'Massimo 10 Istruttori');
END;

/*Il seguente trigger controlla che un cliente può prenotarsi a solo un corso al giorno*/

CREATE OR REPLACE TRIGGER v2
BEFORE INSERT ON Prenotazioni
FOR EACH ROW
DECLARE 
errore EXCEPTION;
id Prenotazioni.Abbonamento%TYPE;
da Prenotazioni.Data_Ora%TYPE;
CURSOR pren_cursor IS SELECT Abbonamento,Data_Ora,Corso FROM Prenotazioni;
vr_pren pren_cursor%ROWTYPE;
BEGIN
OPEN pren_cursor;
	LOOP
		FETCH pren_cursor INTO vr_pren;
		EXIT WHEN pren_cursor%NOTFOUND;
		id:=vr_pren.Abbonamento;
		da:=vr_pren.Data_Ora;
		IF(id=:new.Abbonamento and to_date(to_char(:new.Data_Ora,'dd/mm/yyyy'),'dd/mm/yyyy')=to_date(to_char(da,'dd/mm/yyyy'),'dd/mm/yyyy'))
			THEN RAISE errore;
		END IF;
	END LOOP;
CLOSE pren_cursor;
EXCEPTION
WHEN errore THEN RAISE_APPLICATION_ERROR (-20008, 'Il seguente utente: ' ||id|| ' ha già fatto una prenotazione di un corso nello stesso giorno');
END;

/*Il seguente trigger controlla al momento della prenotazione che l'abbonamento del cliente sia valido*/

CREATE OR REPLACE TRIGGER v3
BEFORE INSERT ON Prenotazioni
FOR EACH ROW
DECLARE
errore exception;
data Clienti.Data_di_Scadenza_ABB%TYPE;
BEGIN
	SELECT Clienti.Data_di_Scadenza_ABB INTO data FROM Clienti WHERE (Clienti.ID_Abbonamento=:new.Abbonamento);
	IF(data<CURRENT_DATE)
		THEN RAISE errore;
	END IF;
EXCEPTION
WHEN errore THEN RAISE_APPLICATION_ERROR (-20009, 'Il seguente utente: ' || :new.Abbonamento || ' non ha un abbonamento valido: Data abbonamento scaduta');
END;