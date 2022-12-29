/**
 * Esta función muestra un formulario de login (para fetch)
 * El botón enviar del formulario deberá invocar a la función doLogin
 * Modifica el tag div con id main en el html
 */

var xml;
function showLogin(){
  let formhtml = `<label>User</label><br>
              <input type ="text" id="user" name ="user" ><br>
              <label> password </label><br>
              <input type ="password" id="password" name ="password"><br>
              <button onclick ="doLogin()">Ingresar</button> 
              <p id="mensaje" ></p>`;
  document.getElementById('main').innerHTML = formhtml;

}

/**
 * Esta función recolecta los valores ingresados en el formulario
 * y los envía al CGI login.pl
 * La respuesta del CGI es procesada por la función loginResponse
 */
function doLogin(){
  let user = document.getElementById('user').value;
  let password = document.getElementById('password').value;
  console.log(user);
  console.log(password);
  let url = 'cgi-bin/login.pl?user='+user+'&password='+password;
  console.log(url);
  var xml;
  let promise = fetch(url);
  promise.then(response=>response.text()).then(data=>
    {
      xml = (new window.DOMParser()).parseFromString(data, "text/xml");
      console.log(xml);
      loginResponse(xml) ;
    }).catch(error=>{
      console.log('Error :', error);
    });

}
/**
 * Esta función recibe una respuesta en un objeto XML
 * Si la respuesta es correcta, recolecta los datos del objeto XML
 * e inicializa la variable userFullName y userKey (e usuario)
 * termina invocando a la funcion showLoggedIn.
 * Si la respuesta es incorrecta, borra los datos del formulario html
 * indicando que los datos de usuario y contraseña no coinciden.
 */
function loginResponse(xml){
  var usuario = xml.getElementsByTagName('user');
  var owner = usuario[0].getElementsByTagName('owner');
  console.log(owner.length);
  if(owner.length==1){
    var ownerValue = owner[0].textContent;
    var firstName = usuario[0].getElementsByTagName('firstName');
    var firstNameValue = firstName[0].textContent;
    var lastName = usuario[0].getElementsByTagName('lastName');
    var lastNameValue = lastName[0].textContent;
    console.log('datos correctos, ingreso');
    userFullName = firstNameValue+" "+ lastNameValue;
    console.log(userFullName);
    userKey = ownerValue;
    console.log(userKey);
    showLoggedIn();
  }else{
    console.log('datos, incorrectos');
    showLogin();
    document.getElementById('mensaje').innerHTML = "Datos incorrectos";
  }
}
/**
 * esta función usa la variable userFullName, para actualizar el
 * tag con id userName en el HTML
 * termina invocando a las functiones showWelcome y showMenuUserLogged
 */
function showLoggedIn(){
  document.getElementById('userName').innerHTML = userFullName;
  showWelcome();
  showMenuUserLogged();
}
/**
 * Esta función crea el formulario para el registro de nuevos usuarios
 * el fomulario se mostrará en tag div con id main.
 * La acción al presionar el bontón de Registrar será invocar a la 
 * función doCreateAccount
 * */
function showCreateAccount(){
  let formhtml = 
    `<label>Username</label><br>
              <input type ="text" id="username" name ="user" ><br>
              <label>Firstname </label><br>
              <input type ="text" id="firstname" name ="firstname"><br>
              <label>Lastname </label><br>
              <input type ="text" id="lastname" name ="lastname"><br>
              <label>Password </label><br>
              <input type ="password" id="password" name ="password"><br>
              <button onclick ="doCreateAccount()">Registrar</button> 
              <p id="mensaje" ></p>`;
  document.getElementById('main').innerHTML = formhtml;


}

/* Esta función extraerá los datos ingresados en el formulario de
 * registro de nuevos usuarios e invocará al CGI register.pl
 * la respuesta de este CGI será procesada por loginResponse.
 */
function doCreateAccount(){
  let user = document.getElementById('username').value;
  let firstName = document.getElementById('firstname').value;
  let lastName = document.getElementById('lastname').value;
  let password = document.getElementById('password').value;
  console.log("datos recogidos:",user,firstname,lastname,password);
  let url = 'cgi-bin/register.pl?userName='+user+'&password='+password+'&firstName='+
    firstName+'&lastName='+lastName;
  console.log(url);
  var xml;
  let promise = fetch(url);
  promise.then(response=>response.text()).then(data=>
    {
      xml = (new window.DOMParser()).parseFromString(data, "text/xml");
      console.log(xml);
      loginResponse(xml) ;
    }).catch(error=>{
      console.log('Error :', error);
    });
}
/*
 * Esta función invocará al CGI list.pl usando el nombre de usuario 
 * almacenado en la variable userKey
 * La respuesta del CGI debe ser procesada por showList
 */
function doList(){
  console.log("este es el owne que sera enviado al cgi",userKey);
  let url = 'cgi-bin/list.pl?owner='+userKey;
  console.log("este cgi se usara",url);
  let promise = fetch(url);
  promise.then(response=>response.text()).then(data=>
    {
      xml = (new window.DOMParser()).parseFromString(data, "text/xml");
      console.log(xml);
      showList(xml);
    }).catch(error=>{
      console.log('Error :', error);
    });
}
/**
 * Esta función recibe un objeto XML con la lista de artículos de un usuario
 * y la muestra incluyendo:
 * - Un botón para ver su contenido, que invoca a doView.
 * - Un botón para borrarla, que invoca a doDelete.
 * - Un botón para editarla, que invoca a doEdit.
 * En caso de que lista de páginas esté vacia, deberá mostrar un mensaje
 * indicándolo.
 */
function showList(xml){
  console.log("se ingreso a la funcion showListi se recibo",xml);
  var  articulos = xml.getElementsByTagName('article');
  var owners = xml.getElementsByTagName('owner');
  var titulos = xml.getElementsByTagName('title');
  console.log("articulo",articulos);
  console.log("tamaño de la coleccion",articulos.length);
  var numArticulos = articulos.length;
  var listhtml="";
  if(numArticulos==0){
    console.log("no tiene ningun articulo");
    html = `<p>No tiene articulos</p>
               `;
  }else{
    console.log("si tiene articulos")
    console.log("esto son",titulos);
    console.log("primer owner and title",owners[0].textContent,titulos[0].textContent);
    console.log(typeof(owners[0].textContent));
    listhtml = "<ol>";
    for (let i=0; i < numArticulos ; i++){
      listhtml += "<li>"+titulos[i].textContent+
        `<button onclick = "doView(`+`'`+owners[i].textContent+`'`+`,`+`'`+ titulos[i].textContent+`'`+`)">View</button>`+
        `<button onclick = "doDelete(`+`'`+owners[i].textContent+`'`+`,`+`'`+ titulos[i].textContent+`'`+`)">Delete</button>`+
        `<button onclick = "doEdit(`+`'`+owners[i].textContent+`'`+`,`+`'`+ titulos[i].textContent+`'`+`)">Edit</button>`+
        "</li> \n";
    }listhtml += "</ol>";

  }

  document.getElementById('main').innerHTML = listhtml;

}

/**
 * Esta función deberá generar un formulario para la creación de un nuevo
 * artículo, el formulario deberá tener dos botones
 * - Enviar, que invoca a doNew 
 * - Cancelar, que invoca doList
 */
function showNew(){
  var formhtml = "";
  formhtml += `
             <label>Titulo</label>
             <input type = "text" id="titulo" name ="titulo" value= ""><br>
             <label > texto</label>
             <textarea style = "width:180px; height:150px" id = "cuadrotext" name ="texto"></textarea>          `+`<button onclick ="doNew()">Enviar</button>`+`
                 <button onclick = "doList()">Cancelar</button>`;
  document.getElementById('main').innerHTML = formhtml;
}

/*
 * Esta función invocará new.pl para resgitrar un nuevo artículo
 * los datos deberán ser extraidos del propio formulario
 * La acción de respuesta al CGI deberá ser una llamada a la 
 * función responseNew
 */
function doNew(){
  let title  = document.getElementById('titulo').value;
  let texto = document.getElementById('cuadrotext').value;
  console.log("datos recogidos:",title,texto);
  let url1 = 'cgi-bin/new.pl?title='+title+'&text='
  let textoencode = encodeURIComponent(texto);
  let url3 = '&owner='+userKey;
  let urlcomple= url1+textoencode+url3;
  console.log(urlcomple)
  var response;
  let promise = fetch(urlcomple);
  promise.then(response=>response.text()).then(data=>
    {
      response = (new window.DOMParser()).parseFromString(data, "text/xml");
      console.log(response);
      responseNew(response) ;
    }).catch(error=>{
      console.log('Error :', error);
    });
}

/*
 * Esta función obtiene los datos del artículo que se envían como respuesta
 * desde el CGI new.pl y los muestra en el HTML o un mensaje de error si
 * correspondiera
 */
function responseNew(response){
  console.log("function responseNew",response);
  let articulo = response.getElementsByTagName('title');
  let text = response.getElementsByTagName('text');
  let textContent = text[0].textContent;
  let lengthTextContent = textContent.length;
  console.log("contenido de text",textContent);
  console.log(lengthTextContent);
  var cuerpohtml="";
  
  if(lengthTextContent>0){
    console.log("tama",articulo[0].textContent,text[0].textContent);
    let titlehtml ="<h1>";
    titlehtml += articulo[0].textContent+"</h1>";
    let texthtml = "<p>";
    texthtml += text[0].textContent+"</p>";
    cuerpohtml += ""+titlehtml+"\n"+texthtml;
  }else{
    console.log("ese dueño no existe")
    cuerpohtml += "<p>Error, usuario no existe o no lleno todos loca campos</p>";
  }
  document.getElementById('main').innerHTML = cuerpohtml;

}

/*
 * Esta función invoca al CGI view.pl, la respuesta del CGI debe ser
 * atendida por responseView
 */
function doView(owner, title){
  console.log('se va a visualizar');
  let url = 'cgi-bin/view.pl?owner='+owner+'&title='+title;
  console.log("la url es ",url);
  var response;
  let promise = fetch(url);
  promise.then(response=>response.text()).then(data=>
    {
      /*response = (new window.DOMParser()).parseFromString(data, "text/html");*/ /*esta linea cambia la respuesta string a un objeto DOM*/
      console.log("esto sale",data);
      responseView(data) ;
    }).catch(error=>{
      console.log('Error :', error);
    });
}
/*
 * Esta función muestra la respuesta del cgi view.pl en el HTML o 
 * un mensaje de error en caso de algún problema.
 */
function responseView(response){
  console.log("esta data ha pasado",response);  /*Se tien un objto html traducito*/
  /*let body = response.getElementsByTagName('body'); /*Se hizo pruebas en consola*/
  /*let tagshtml = body[0].childNodes;  /*esto es un arry de todos los tags de body*/
  /*console.log("estos son lso tags de body", tagshtml);
  let nuevoMain = "";
  for (var i=0;i<tagshtml.length;i++){
    nuevoMain += tagshtml[i].outerHTML+"\n";
  }
  console.log("nuevoMain",nuevoMain);*/
  document.getElementById('main').innerHTML = response ;
}
/*
 * Esta función invoca al CGI delete.pl recibe los datos del artículo a 
 * borrar como argumentos, la respuesta del CGI debe ser atendida por doList
 */
function doDelete(owner, title){
  console.log('se va a eliminar',owner,title);
  let url = 'cgi-bin/delete.pl?owner='+owner+'&title='+title;
  console.log("la url es ",url);
  var xml;
  let promise = fetch(url);
  promise.then(response=>response.text()).then(data=>
    {
      xml = (new window.DOMParser()).parseFromString(data, "text/xml");
      console.log("esto se eliminar",xml);
      doList() ;
    }).catch(error=>{
      console.log('Error :', error);
    });
}
/*
 * Esta función recibe los datos del articulo a editar e invoca al cgi
 * article.pl la respuesta del CGI es procesada por responseEdit
 */
function doEdit(owner, title){
  console.log('se va a editarA;',owner,title);
  let url = 'cgi-bin/article.pl?owner='+owner+'&title='+title;
  console.log("la url es ",url);
  var xml;
  let promise = fetch(url);
  promise.then(response=>response.text()).then(data=>
    {
      xml = (new window.DOMParser()).parseFromString(data, "text/xml");
      console.log("esto sale",xml);
      responseEdit(xml) ;
    }).catch(error=>{
      console.log('Error :', error);
    });
}
/*
 * Esta función recibe la respuesta del CGI data.pl y muestra el formulario 
 * de edición con los datos llenos y dos botones:
 * - Actualizar que invoca a doUpdate
 * - Cancelar que invoca a doList
 */
function responseEdit(xml){
  console.log ("son tres tags owner, title, text");
  console.log("vamos a editar",xml);
  let articles = xml.getElementsByTagName('article');   /*solo hay un articulo, se guarda en array*/
  let hojasxml= articles[0].childNodes;           /*obtengo todas las hojas de <article>*/
  console.log(hojasxml.length);
  let owner = hojasxml[1].textContent;        /*los espacios son considerados un nodos*/
  let title = hojasxml[3].textContent;
  let texto =hojasxml[5].textContent;             /*los numeros impares seria los nodos con text*/
  console.log("orden de las hojas",owner,title,texto);

  var formhtml = "";
  formhtml += `
             <label>Titulo</label>
             <h1>`+title+`</h1><br>
             <label > texto</label>
             <textarea style = "width:180px; height:150px" id = "cuadrotext" name ="texto">`+
    texto+`</textarea><br>
             <button onclick ="doUpdate(`+`'`+title+`'`+`)">Actualizar</button>`+`
                 <button onclick = "doList()">Cancelar</button>`;
  document.getElementById('main').innerHTML = formhtml;
}
/*
 * Esta función recibe el título del artículo y con la variable userKey y 
 * lo llenado en el formulario, invoca a update.pl
 * La respuesta del CGI debe ser atendida por responseNew
 */
function doUpdate(title){
  let texto = document.getElementById('cuadrotext').value;
  console.log("es el texto a actualizar",texto);
  let url1 = 'cgi-bin/update.pl?title='+title+'&text='
  let textoencode = encodeURIComponent(texto);
  let url3 = '&owner='+userKey;
  let urlcomple= url1+textoencode+url3;
  console.log("url completa",urlcomple);
  var response;
  let promise = fetch(urlcomple);
  promise.then(response=>response.text()).then(data=>
    {
      response = (new window.DOMParser()).parseFromString(data, "text/xml");
      console.log("esto sale",response);
      responseNew(response);
    }).catch(error=>{
      console.log('Error :', error);
    });
}

