function checkFields() {
    if (document.eform.title.value.length > 0 && document.eform.author.value.length > 0 && document.eform.body.value.length > 0) {
        return true;
    }
    else {
        alert ('Please fill out Title, Author and Text!');
        document.eform.title.focus();
        return false;
    }
}
