//
//  ListaAnotacoesViewController.swift
//  Notas Diarias
//
//  Created by Renato Savoia Girão
//

import UIKit
import CoreData

class ListaAnotacoesViewController: UITableViewController {
    
    
    var anotacoes: [NSManagedObject] = []
    var gerenciadorObjetos: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //inicializa gerenciador de objetos
        let appDelagate = UIApplication.shared.delegate as! AppDelegate
        gerenciadorObjetos = appDelagate.persistentContainer.viewContext
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.recuperarAnotacoes()
        
    }
    
    func recuperarAnotacoes(){
        
        //Recupera todas as anotações
        let requisicaoAnotacoes = NSFetchRequest<NSFetchRequestResult>(entityName: "Cadastros")
        
        do{
            
            //Recupera anotações
            let anotacoesRecuperadas = try gerenciadorObjetos.fetch( requisicaoAnotacoes )
            self.anotacoes = anotacoesRecuperadas as! [NSManagedObject]
            
            self.tableView.reloadData()
            
        }catch let erro as NSError{
            print("Erro ao recuperar anotações: erro \(erro.description) ")
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.anotacoes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        func colorForIndex(index: Int) -> UIColor {
//            let itemCount = anotacoes.count - 1
//            let color = (CGFloat(index) / CGFloat(itemCount)) * 0.6
//            return UIColor(red: 1.0, green: color, blue: 0.0, alpha: 1.0)
//        }
        
        
        let anotacao = anotacoes[ indexPath.row ]
        let dataCriacao = anotacao.value(forKey: "dataCriacao") as! NSDate
      //  let nomeEscrito = anotacao.value(forKey: "nome")
        let emailEscrito = anotacao.value(forKey: "email")
//        let sexoEscrito = anotacao.value(forKey: "sexo")
//        let seTrabalhaNaBerriniEscrito = anotacao.value(forKey: "seTrabalhaNaBerrini")
//        let faixaEtariaEscrita = anotacao.value(forKey: "faixaEtaria")
//        let areaEscrita = anotacao.value(forKey: "areaDeAtuacao")
//        let telefoneEscrito = anotacao.value(forKey: "telefoneDoUsuario")
//        let empresaQueTrabalhaEscrito = anotacao.value(forKey: "qualEmpresaTrabalha")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm"
        let novaData = dateFormatter.string(from: dataCriacao as Date )
        let emailSalvoPraTableView = emailEscrito as! String
        
        let celula = self.tableView.dequeueReusableCell(withIdentifier: "celula", for: indexPath)
        celula.textLabel?.text = anotacao.value(forKey: "nome") as? String
        celula.detailTextLabel?.text = emailEscrito as? String
        
        return celula
        
    }
    
//    func colorForIndex(index: Int) -> UIColor {
//        let itemCount = anotacoes.count - 1
//        let color = (CGFloat(index) / CGFloat(itemCount)) * 0.6
//        return UIColor(red: 1.0, green: color, blue: 0.0, alpha: 1.0)
//    }
//    
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
//                            forRowAtIndexPath indexPath: NSIndexPath) {
//        cell.backgroundColor = colorForIndex(index: indexPath.row)
//    }
//        
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        let anotacao = self.anotacoes[ indexPath.row ]
        self.performSegue(withIdentifier: "verAnotacao", sender: anotacao )
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            let anotacao = self.anotacoes[ indexPath.row ]
            self.gerenciadorObjetos.delete( anotacao )
            self.anotacoes.remove(at: indexPath.row )
            
            //atualiza listagem
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            //self.tableView.reloadData()
            
            do{
                try self.gerenciadorObjetos.save()
            }catch let erro as NSError{
                print("Erro ao remover item \(erro) ")
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "verAnotacao" {
            
            let anotacaoViewController = segue.destination as! AnotacaoViewController
            anotacaoViewController.anotacao = sender as? NSManagedObject
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
