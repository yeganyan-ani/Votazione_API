//// Definizione licenza e versione di solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 < 0.9.0;

// Definizione del contratto
contract Elezioni{

    //  Struttura che contiene le informazioni del Candidato
    struct Candidato{
        // Nome del candidato
        string nome;
        // Partito di appartenenza
        string partito;
        // Descrizione del candidato
        string descrizione;
        // Numero di voti che il candidato ha ottenuto
        uint numeroVoti;
    }

    // Struttura che contiene le informazioni dell' Elettore
    struct Elettore{
        // Nome dell'elettore
        string nome;
        /* Booleano per verificare se l'elettore è autorizzato a votare oppure no
        vero = l'elettore è autorizzato a votare, falso = l'elettore non è autorizzato a votare */
        bool autorizzato;       
        // Indice della lista dei candidati che corrisponde alla posizione del candidato che l'elettore vuole votare
        uint identificativo;
        /* Booleano per verificare se l'elettore ha già votato oppure no
        vero = l'elettore ha già votato, falso = l'elettore deve ancora votare */
        bool votato;
    }

    /* Indirizzo del propietario dello smart contract; 
    è pubblico in modo che tutti possano vedere chi è il proprietario dello smart contract */
    address public proprietario;
    
    // Nome/Titolo della votazione
    string public nomeVotazione;

    // Mappo l'indirizzo a un elettore; ogni indirizzo avrà la struttura dell'elettore
    mapping(address => Elettore) public elettori;
    
    // Elenco candidati
    Candidato[] public candidati;
    
    // Numero totale di voti
    uint public votiTotali;

    /* Modificatore
    Solo il proprietario dello smart contract può aggiungere nuovi candidati;
    Solo il proprietario può richiamare questa funzione */
    modifier soloProprietario(){
        require(msg.sender == proprietario);
        _;
    }

    // Definizione della funzione di inizio della votazione
    function inizioVotazione(string memory _nomeVotazione) public{
        /* La persona che ha distribuito o creato il contratto diventerà il proprietario della votazione
        Persona che ha attivato la votazione (che ha distribuito il contratto) */
        proprietario = msg.sender;
        nomeVotazione = _nomeVotazione;
    }

    /* Definizione della funzione che permette di aggiungere un nuovo candidato.
    Prende come parametro di input il nome, il partito e la descrizione del nuovo candidato */
    function aggiungiCandidato(
        string memory _nomeCandidato, 
        string memory _partito, 
        string memory _descrizione
        ) soloProprietario public {
        // Inizializzazione del nuovo candidato con il nome, il partito e 
        // la descrizione, passati come parametri, e numero di voti pari a 0
        candidati.push(Candidato(_nomeCandidato, _partito, _descrizione, 0));
    }

    /* Definizione della funzione che permette di autorizzare un voto.
    Prende come parametro di input l'indirizzo della persona che sta votando */
    function autorizzaElettore(address _indirizzoElettore) soloProprietario public{
        elettori[_indirizzoElettore].autorizzato = true;
    }

    //  Definizione della funzione che permette di contare il numero di candidati
    function getNumeroCandidati() public view returns(uint){
        return candidati.length;
    }

    // Definizione della funzione che permette di effettuare la votazione
    function votazione(uint indiceCandidato) public{
        // msg.sender restituisce l'indirizzo dell'elettore che attualmente sta "usando" lo smart contract
       /* Controllo che l'elettore non abbia già votato
         se è falso l'elettore non ha ancora votato quindi si va avanti */
       require(!elettori[msg.sender].votato);   
        /* Controllo che l'elettore sia autorizzato a votare
        se è falso significa che l'elettore non ha ancora votato quindi si va avanti */
       require(elettori[msg.sender].autorizzato);
       // Votazione per il candidato scelto
       elettori[msg.sender].identificativo = indiceCandidato;
       // Registro che l'elettore ha effettuato il suo voto e quindi non dovrebbe essere in grado di votare di nuovo
       elettori[msg.sender].votato = true;
       // Incremento di 1 il numero di voti per il candidato che è stato apena votato dall'elettore
       candidati[indiceCandidato].numeroVoti++;
       // Incremento di 1 il numero totale di voti effettuati
       votiTotali++;
    }

    // Definizione della funzione che restituisce il numero di voti totali effettuati
    function getVotiTotali() public view returns(uint){
        return votiTotali;
    }
    
    // Definizione della funzione che restituisce le informazioni relative al candidato
    function infoCandidato(uint index) public view returns(Candidato memory){
        return candidati[index];
    }
}