using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GamePanel : MonoBehaviour
{

    public GameObject Selection2_Environment;
    public GameObject Selection2_Animal;

    public GameObject Selection3_Environment;

    public GameObject Selection3_Animal;
    public GameObject Selection3_Carnivore;
    public GameObject Selection3_Herbivore;
    public GameObject Selection3_Omnivore;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void SelectEnvironment()
    {
        Debug.Log("Env");
        Selection2_Environment.gameObject.SetActive(true);
        Selection2_Animal.gameObject.SetActive(false);
        Selection3_Environment.gameObject.SetActive(false);
        Selection3_Animal.gameObject.SetActive(false);
    }

    public void SelectAnimal()
    {
        Debug.Log("Ani");
        Selection2_Animal.gameObject.SetActive(true);
        Selection2_Environment.gameObject.SetActive(false);
        Selection3_Environment.gameObject.SetActive(false);
        Selection3_Animal.gameObject.SetActive(false);
    }

    public void SelectCarbivore()
    {
        Selection3_Animal.gameObject.SetActive(true);
        Selection3_Carnivore.gameObject.SetActive(true);
        Selection3_Herbivore.gameObject.SetActive(false);
        Selection3_Omnivore.gameObject.SetActive(false);
    }

    public void SelectHerbivore()
    {
        Selection3_Animal.gameObject.SetActive(true);
        Selection3_Herbivore.gameObject.SetActive(true);
        Selection3_Carnivore.gameObject.SetActive(false);
        Selection3_Omnivore.gameObject.SetActive(false);
    }

    public void SelectOmnivore()
    {
        Selection3_Animal.gameObject.SetActive(true);
        Selection3_Omnivore.gameObject.SetActive(true);
        Selection3_Carnivore.gameObject.SetActive(false);
        Selection3_Herbivore.gameObject.SetActive(false);
    }


}
