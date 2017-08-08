//
//  ViewController.swift
//  Notas Diarias
//
//  Created by Renato Savoia Girão


import UIKit
import CoreData
import FirebaseDatabase

class AnotacaoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //928785A2-09D9-4BD4-8D37-4CA728BA4613
    //Caminho para acesso ao arquivo DB:   /Users/flexadm/Library/Developer/CoreSimulator/Devices/EE80AAC8-918E-495B-AD8F-F73CEDFCC908/data/Containers/Data/Application/0A02A447-2CC6-4D51-B79B-23620644C809/Library/Application Support/
    
    var idCadastro: String = "1"
    let arrayFaixaEtaria = ["18 a 30 anos", "31 a 40 anos", "51 a 60 anos", "Acima de 61 anos"]
    let arrayAreaDeAtuacao = ["Marketing", "Comercial", "RH", "Tecnologia", "Logistica", "Outra"]
    let arraySexo = ["Masculino", "Feminino"]
    let arrayTrabalhaNaBerrini = ["Sim", "Não"]
  
    @IBOutlet weak var salvarButton: UIBarButtonItem!
    @IBOutlet weak var TFNome: UITextField!
    @IBOutlet weak var TFEmail: UITextField!
    @IBOutlet weak var TFTelefone: UITextField!
    @IBOutlet weak var pickerViewFaixaEtaria: UIPickerView!
    @IBOutlet weak var pickerViewTrabalhaNaBerrini: UIPickerView!
    @IBOutlet weak var pickerViewAreaDeAtuacao: UIPickerView!
    @IBOutlet weak var pickerViewSexo: UIPickerView!
    @IBOutlet weak var TFqualEmpresaTrabalha: UITextField!
    @IBOutlet weak var TFqualAreaDeAtuacao: UITextField!
    
    //Dados obrigatórios que serão preenchidos pelo usuário
    var faixaEtariaDoUsuario = ""
    var sexoDoUsuario = ""
    var SeUsuarioTrabalhaNaBerrini = ""
    var AreaDeAtuacaoDoUsuario: String = "Marketing"
    
    //Dados condicionais
    var empresaQueTrabalha = ""
    var outraAreaDeAtuacaoDoUsuario = ""
    var gerenciadorObjetos: NSManagedObjectContext!
    var anotacao: NSManagedObject!
    
    let bancoDeDadosUsuarios = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        TFqualAreaDeAtuacao.isUserInteractionEnabled = false
        salvarButton.isEnabled = false
        
        let cliqueFora: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(cliqueFora)
        
        
        //Valores Padrão para os PickerViews que não forem alterados
        faixaEtariaDoUsuario = "18 a 30 anos"
        sexoDoUsuario = "Masculino"
        SeUsuarioTrabalhaNaBerrini = "Sim"
        AreaDeAtuacaoDoUsuario = "Marketing"
        empresaQueTrabalha = "Não Declarou onde trabalha"
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        //configuracoes iniciais
        self.TFNome.becomeFirstResponder()
        
        //Atribuindo os delegates e os Data Source
        self.pickerViewFaixaEtaria.delegate = self
        self.pickerViewFaixaEtaria.dataSource = self
        
        self.pickerViewTrabalhaNaBerrini.delegate = self
        self.pickerViewTrabalhaNaBerrini.dataSource = self
        
        self.pickerViewSexo.delegate = self
        self.pickerViewSexo.dataSource = self
        
        self.pickerViewAreaDeAtuacao.delegate = self
        self.pickerViewAreaDeAtuacao.dataSource = self
        
        //inicializa gerenciador de objetos
        let appDelagate = UIApplication.shared.delegate as! AppDelegate
        gerenciadorObjetos = appDelagate.persistentContainer.viewContext
        
        self.TFqualAreaDeAtuacao.delegate = self
        
        self.TFqualEmpresaTrabalha.delegate = self
        
        self.TFTelefone.delegate = self
        
        self.TFNome.delegate = self
        
        self.TFEmail.delegate = self
   
        
       
        
        if anotacao != nil {
            //se existir uma anotação, deve editar
            
            self.TFNome.text = anotacao.value(forKey: "nome") as? String
            self.TFEmail.text = anotacao.value(forKey: "email") as? String
            self.SeUsuarioTrabalhaNaBerrini = anotacao.value(forKey: "seTrabalhaNaBerrini") as! String
            self.faixaEtariaDoUsuario = anotacao.value(forKey: "faixaEtaria") as! String
            self.sexoDoUsuario = anotacao.value(forKey: "sexo") as! String
            self.AreaDeAtuacaoDoUsuario = anotacao.value(forKey: "areaDeAtuacao") as! String
            self.TFTelefone.text = anotacao.value(forKey: "telefoneDoUsuario") as? String
            self.empresaQueTrabalha = anotacao.value(forKey: "qualEmpresaTrabalha") as! String
            
        }else{
            //se não existe anotação, anotação nova, vamos self.TFNome.text = ""
            self.TFEmail.text = ""
            self.TFTelefone.text = ""
            self.TFqualAreaDeAtuacao.text = ""
            self.TFqualEmpresaTrabalha.text = ""
        }
        
        
    }
    
    @IBAction func salvarAnotacao(_ sender: AnyObject) {
        
        if  TFqualEmpresaTrabalha.text != "" {
            
            empresaQueTrabalha = TFqualEmpresaTrabalha.text!
            
        } else if TFqualEmpresaTrabalha.text == "" && SeUsuarioTrabalhaNaBerrini == "Sim"  {
            
            empresaQueTrabalha = "Não quis declarar onde trabalha"
            
        } else {
            
            SeUsuarioTrabalhaNaBerrini = "Nao"
            empresaQueTrabalha = "Nao trabalha na Berrini"
            
        }
        
        if AreaDeAtuacaoDoUsuario == "Outra" && TFqualAreaDeAtuacao.text == "" {
            TFqualAreaDeAtuacao.isUserInteractionEnabled = true
            AreaDeAtuacaoDoUsuario = "Nao quis declarar a area de Atuacao"
            
        }
        
        if AreaDeAtuacaoDoUsuario == "Outra" && TFqualAreaDeAtuacao.text != "" {
            TFqualAreaDeAtuacao.isUserInteractionEnabled = true
            AreaDeAtuacaoDoUsuario = TFqualAreaDeAtuacao.text!
        }
            
        else {
            
            TFqualAreaDeAtuacao.text = ""
        }

        
        if anotacao != nil {
            //existe uma anotação, vamos atualizá-la
            self.atualizar()
            print ("\nFunção atualizar!\n")
            
        }else{
            //anotação nova, vamos salvá-la
            if anotacao == nil {
                self.salvar()
                print ("\nFuncão salvar!\n")
            }
        }
        
        //Retorna para a tela inicial
        _ = self.navigationController?.popToRootViewController(animated: true)
        
        let nomeDoUsuario = (TFNome.text)!
        let emailDoUsuario = (TFEmail.text)!
        let telefoneDoUsuario = (TFTelefone.text)!
        
        
        bancoDeDadosUsuarios.childByAutoId().child(nomeDoUsuario).setValue(["Nome" : nomeDoUsuario, "Email": emailDoUsuario, "Telefone" : telefoneDoUsuario, "Trabalha na Berrini?": SeUsuarioTrabalhaNaBerrini, "Faixa Etaria": faixaEtariaDoUsuario, "Sexo": sexoDoUsuario, "Area de Atuacao": AreaDeAtuacaoDoUsuario, "Qual Empresa trabalha?": empresaQueTrabalha])
     
        mostrarNoPrintOsDados()
        
            }
    
    func mostrarNoPrintOsDados() {
        
        print ("ESSES DADOS FORAM SALVOS")
        print ("Nome do usuário: \(TFNome.text!)")
        print ("Email do usuário: \(TFEmail.text!)")
        print ("A faixa etária do usuário é: \(faixaEtariaDoUsuario)")
        print ("Sexo do usuário é: \(sexoDoUsuario)")
        print ("O usuário trabalha na Berrini? Resposta é: \(SeUsuarioTrabalhaNaBerrini)")
        print ("Onde o usuário trabalha? Resposta é: \(empresaQueTrabalha)")
        print ("Área de atuação do usuário: \(AreaDeAtuacaoDoUsuario)\n\n")
    }
    
    func dismissKeyboard(){
        
        view.endEditing(true)
        if TFNome.text == "" {
            salvarButton.isEnabled = false
            view.endEditing(true)
        }else{
            view.endEditing(true)
            salvarButton.isEnabled = true
        }
        

        mostrarNoPrintOsDados()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField == self.TFNome) {
            
            if TFNome.text == "" {
                salvarButton.isEnabled = false
                view.endEditing(true)
            }else{
                view.endEditing(true)
                salvarButton.isEnabled = true
            }
            
            self.TFEmail.becomeFirstResponder()
        }
        else if (textField == self.TFEmail) {
            
            self.TFTelefone.becomeFirstResponder()
        }
        else if (textField == self.TFTelefone) {
            
            self.TFqualEmpresaTrabalha.becomeFirstResponder()
            
        } else if (textField == self.TFqualEmpresaTrabalha) {
            
            self.TFqualAreaDeAtuacao.becomeFirstResponder()
            empresaQueTrabalha = TFqualEmpresaTrabalha.text!
            
        } else if (textField == self.TFqualAreaDeAtuacao) {
            
            AreaDeAtuacaoDoUsuario = TFqualAreaDeAtuacao.text!
            dismissKeyboard()
        }
        
        return true
        
    }
    
    func atualizar(){
        
        
        if (AreaDeAtuacaoDoUsuario) == "Outra"
            
        {   if TFqualAreaDeAtuacao.text == "" {
            AreaDeAtuacaoDoUsuario = "Nao quis declarar a Area de Atuacao"
            
        }   else  {
            AreaDeAtuacaoDoUsuario = TFqualAreaDeAtuacao.text!
            
            }
            
            print("Nome do usuário: \(TFNome.text!)")
            print("Email do usuário: \(TFEmail.text!)")
            print ("A faixa etária do usuário é: \(faixaEtariaDoUsuario)")
            print ("Sexo do usuário é: \(sexoDoUsuario)")
            print ("O usuário trabalha na Berrini? Resposta é: \(SeUsuarioTrabalhaNaBerrini)")
            print ("Onde o usuário trabalha? Resposta é: \(empresaQueTrabalha)")
            print ("SIM OUTRAS: Área de atuação do usuário: \(AreaDeAtuacaoDoUsuario)\n\n")
            
        } else {
            
            
            
            print("Nome do usuário: \(TFNome.text!)")
            print("Email do usuário: \(TFEmail.text!)")
            print ("A faixa etária do usuário é: \(faixaEtariaDoUsuario)")
            print ("Sexo do usuário é: \(sexoDoUsuario)")
            print ("O usuário trabalha na Berrini? Resposta é: \(SeUsuarioTrabalhaNaBerrini)")
            print ("Onde o usuário trabalha? Resposta é: \(empresaQueTrabalha)")
            print ("NAO OUTRAS: Área de atuação do usuário: \(AreaDeAtuacaoDoUsuario)\n\n")
            
        }

        anotacao.setValue( NSDate() , forKey: "dataCriacao")
        anotacao.setValue( self.TFNome.text , forKey: "nome")
        anotacao.setValue( self.TFEmail.text , forKey: "email")
        anotacao.setValue( self.TFTelefone.text , forKey: "telefoneDoUsuario")
        anotacao.setValue( SeUsuarioTrabalhaNaBerrini, forKey: "seTrabalhaNaBerrini")
        anotacao.setValue( faixaEtariaDoUsuario, forKey: "faixaEtaria")
        anotacao.setValue( sexoDoUsuario, forKey: "sexo")
        anotacao.setValue( self.TFqualAreaDeAtuacao.text, forKey: "areaDeAtuacao")             //
        anotacao.setValue( empresaQueTrabalha, forKey: "QualEmpresaTrabalha")
        
        do{
            try gerenciadorObjetos.save()
        }catch let erro as NSError {
            print("Erro ao atualizar dados \(erro)")
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if  (textField == self.TFTelefone) {
            
        
            if (TFTelefone.text! != "0") {
                
                return false }
            if (TFTelefone.text! != "1") {
                
                return false }
            if (TFTelefone.text! != "2") {
                
                return false }
            if (TFTelefone.text! != "3") {
                
                return false }
            if (TFTelefone.text! != "4") {
                
                return false }
            if (TFTelefone.text! != "5") {
                
                return false }
            if (TFTelefone.text! != "6") {
                
                return false }
            if (TFTelefone.text! != "7") {
                
                return false }
            if (TFTelefone.text! != "8") {
                
                return false }
            if (TFTelefone.text! != "9") {
                
                return false
            
            } else {
                
                return true
            }
        
        }else {
            
            return true
        }
    }


    func salvar(){
        
        //cria objeto para anotacao
        let novaAnotacao = NSEntityDescription.insertNewObject(forEntityName: "Cadastros", into: gerenciadorObjetos )
        
        //configura anotacao
        
        //novaAnotacao.setValue( idDoCadastro , forKey: "idDeCadastro")
        
        novaAnotacao.setValue( NSDate() , forKey: "dataCriacao")
        novaAnotacao.setValue( self.TFNome.text, forKey: "nome")
        novaAnotacao.setValue( self.TFEmail.text, forKey: "email")
        novaAnotacao.setValue( self.TFTelefone.text, forKey: "telefoneDoUsuario")
        novaAnotacao.setValue( empresaQueTrabalha, forKey: "qualEmpresaTrabalha")
        novaAnotacao.setValue( SeUsuarioTrabalhaNaBerrini , forKey: "seTrabalhaNaBerrini")
        novaAnotacao.setValue( faixaEtariaDoUsuario , forKey: "faixaEtaria")
        novaAnotacao.setValue( sexoDoUsuario, forKey: "sexo")
        novaAnotacao.setValue( AreaDeAtuacaoDoUsuario , forKey: "areaDeAtuacao")
        novaAnotacao.setValue( empresaQueTrabalha , forKey: "qualEmpresaTrabalha")
        
        
        do{
            try gerenciadorObjetos.save()
        }catch let erro as NSError {
            print("Erro ao adicionar anotação: erro \(erro.description) ")
        }
        
    }
    
    // MARK: - Métodos de UIPickerViewDataSource
    
    // Método que define a quantidade de components (colunas) do pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        if pickerView == pickerViewFaixaEtaria
        {
            return 1
        }
        else if pickerView == pickerViewAreaDeAtuacao
        {
            return 1
        }
        else if pickerView == pickerViewSexo
        {
            return 1
        }
        else {
            
            return 1
        }
    }
    
    
    // Método que define a quantidade de linhas para cada component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == pickerViewFaixaEtaria
        {
            return self.arrayFaixaEtaria.count
        }
        else if pickerView == pickerViewAreaDeAtuacao
        {
            return self.arrayAreaDeAtuacao.count
        }
        else if pickerView == pickerViewSexo
        {
            return self.arraySexo.count
        }
        else {
            
            return self.arrayTrabalhaNaBerrini.count
        }
    }
    
 
    // MARK: - Métodos de UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        if pickerView == pickerViewFaixaEtaria {
            return ("\(arrayFaixaEtaria[row])")
        }
        if pickerView == pickerViewSexo {
            return ("\(arraySexo[row])")
            
        }
        if pickerView == pickerViewTrabalhaNaBerrini {
            return ("\(arrayTrabalhaNaBerrini[row])")
            
        }else{
            return ("\(arrayAreaDeAtuacao[row])")
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == pickerViewFaixaEtaria {
            
            faixaEtariaDoUsuario = (arrayFaixaEtaria[row])
            print ("Idade do usuário: \(faixaEtariaDoUsuario)")
            
        }
        else if pickerView == pickerViewSexo {
            
            sexoDoUsuario = (arraySexo[row])
            print ("Sexo do usuário: \(sexoDoUsuario)")
        }
        else if pickerView == pickerViewTrabalhaNaBerrini {
            TFqualEmpresaTrabalha.isUserInteractionEnabled = true
            if (row) == 0 && TFqualEmpresaTrabalha.text != "" {
                TFqualEmpresaTrabalha.isUserInteractionEnabled = true
                empresaQueTrabalha = TFqualEmpresaTrabalha.text!
                
            } else if (row) == 0 && TFqualEmpresaTrabalha.text == "" {
                print (row)
                empresaQueTrabalha = "Não quis declarar onde trabalha"
                TFqualEmpresaTrabalha.isUserInteractionEnabled = true
            
            } else {
                SeUsuarioTrabalhaNaBerrini = (arrayTrabalhaNaBerrini[row])
                SeUsuarioTrabalhaNaBerrini = ("Não")
                empresaQueTrabalha = "Não trabalha na Berrini"
                TFqualEmpresaTrabalha.isUserInteractionEnabled = false
                TFqualEmpresaTrabalha.text = ""
            }
            mostrarNoPrintOsDados()
            
            
            
            //            if (arrayTrabalhaNaBerrini[row]) == "Sim" {
            //                TFqualEmpresaTrabalha.isUserInteractionEnabled = true
            //
            //                if TFqualEmpresaTrabalha.text != "" {
            //                    empresaQueTrabalha = TFqualEmpresaTrabalha.text!
            //
            //                } else if (TFqualEmpresaTrabalha.text == "") {
            //                    empresaQueTrabalha = "Não quis declarar"
            //
            //                } else {
            //                    empresaQueTrabalha = "ultima condicao!"
            //                    print ("")
            //                }
            //
            //                SeUsuarioTrabalhaNaBerrini = (arrayTrabalhaNaBerrini[row])
            //                print ("Usuario trabalha na Berrini? A reposta é \(SeUsuarioTrabalhaNaBerrini)")
            //
            //            }else{
            //
            //                TFqualEmpresaTrabalha.isUserInteractionEnabled = false
            //                TFqualEmpresaTrabalha.text = ""
            //                empresaQueTrabalha = "Não trabalha na Berrini"
            //                SeUsuarioTrabalhaNaBerrini = "Não"
            //
            //            }
            //
            //           mostrarNoPrintOsDados()
            
            
            //PICKERVIEW DE AREA DE ATUAÇÃO ABAIXO
        }else{
            TFqualAreaDeAtuacao.isUserInteractionEnabled = false
            if (arrayAreaDeAtuacao[row]) == "Outra" && TFqualAreaDeAtuacao.text == "" {
                TFqualAreaDeAtuacao.isUserInteractionEnabled = true
                AreaDeAtuacaoDoUsuario = "Não quis declarar a Área de Atuação"
                
            }
            
            if (arrayAreaDeAtuacao[row]) == "Outra" && TFqualAreaDeAtuacao.text != "" {
                TFqualAreaDeAtuacao.isUserInteractionEnabled = true
                AreaDeAtuacaoDoUsuario = TFqualAreaDeAtuacao.text!
            }
                
            else if (arrayAreaDeAtuacao[row]) != "Outra" {
                AreaDeAtuacaoDoUsuario = (arrayAreaDeAtuacao[row])
                TFqualAreaDeAtuacao.isUserInteractionEnabled = false
                TFqualAreaDeAtuacao.text = ""
            } else {
                AreaDeAtuacaoDoUsuario = (arrayAreaDeAtuacao[row])
                TFqualAreaDeAtuacao.isUserInteractionEnabled = true
                TFqualAreaDeAtuacao.text = ""
            }
            
            mostrarNoPrintOsDados()
            
        }
    }
}
