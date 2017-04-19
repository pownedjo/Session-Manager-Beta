import UIKit
import SCLAlertView

class SessionVC: UIViewController
{
    @IBOutlet weak var sessionTableView: UITableView!
    
    var tableViewSessionData: Array<Session?> = [] // Array of Session to populate TableView
    lazy var sessionsManager = { return SessionModelController.sessionSharedInstance }()
    var sessionToPass: Session! // Session instance to pass to SessionDetailVC
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        sessionTableView.tableFooterView = UIView()  // Hide empty cells in tableView
        sessionTableView.delegate = self
        sessionTableView.dataSource = self
    }

    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)
        reloadSessionDatas()            // Grab Session datas and put in table View Arrays
        sessionTableView.reloadData()   // Refrsh Table View Datas
    }
    
    
    func reloadSessionDatas()
    {
        if sessionsManager.getAllSessions() == nil
        {
            print("No datas in Session Manager")    // Handle that case - do nothing
        }
        else
        {
            tableViewSessionData = sessionsManager.getAllSessions()!
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let backItem = UIBarButtonItem()
        backItem.title = "Retour"
        navigationItem.backBarButtonItem = backItem // Will be shown in the next view controller being pushed
        
        if segue.identifier == "goToDetailSession"
        {
            let detailViewController = segue.destination as! SessionDetailVC
            detailViewController.detailSession = sessionToPass
        }
    }
}




/* TABLEVIEW DELEGATE && DATASOURCE METHODS */
extension SessionVC: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tableViewSessionData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCellID")! as! SessionTableViewCell
        
        if tableViewSessionData[indexPath.row]?.title == ""
        {
             cell.titleSessionLabel.text = "Session \(indexPath.row)"   // Default title
        }
        else
        {
            cell.titleSessionLabel.text = tableViewSessionData[indexPath.row]?.title
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        sessionToPass = tableViewSessionData[indexPath.row]
        self.performSegue(withIdentifier: "goToDetailSession", sender: nil) // Go to next VC
    }

    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        // Swipe to Delete Action - Delete given Session
        let delete = UITableViewRowAction(style: .destructive, title: "Supprimer") { (action, indexPath) in
            
            if self.sessionsManager.delete(session: self.tableViewSessionData[indexPath.row]!)
            {
                self.tableViewSessionData.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            else
            {
                SCLAlertView().showError("Erreur", subTitle: "Une erreur s'est produite lors de la suppresion de la session, veuillez réessayer. Merci!")
            }
        }
        
        // Swipe to Edit Action - Modify Session Title
        let edit = UITableViewRowAction(style: .normal, title: "Modifier Titre") { (action, indexPath) in
            
            // Custom AlertView (Maybe need to handle Keyboard here)
            let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
            let titleAlert = SCLAlertView(appearance: appearance)
            let txt = titleAlert.addTextField("Entrer un nouveau titre")
            
            titleAlert.addButton("Ok")
            {
                if txt.text != ""
                {
                    self.tableViewSessionData[indexPath.row]?.setTitle(titleSession: txt.text!)
                    self.sessionTableView.reloadData()
                }
            }
            titleAlert.showEdit("Modifier Titre", subTitle: "Entrer un titre pour cette session")
        }
        edit.backgroundColor = UIColor.lightGray
        return [delete, edit]
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
}
