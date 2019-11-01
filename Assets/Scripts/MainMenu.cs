using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    public GameObject gameCamera;

    // Buttons
    public GameObject PlayButton;
    public GameObject WikiButton;
    public GameObject SettingsButton;
    public GameObject BackButton;
    public GameObject ClosePanelButton;
    public GameObject TerrainSelections;

    // Panels
    public GameObject WikiPanel;
    public GameObject SettingsPanel;

    // Control Booleans
    public bool cameraPlay;
    public bool cameraBack;

    // Loading
    public GameObject LoadingBar;

    // Start is called before the first frame update
    void Start()
    {
        cameraPlay = false;
        cameraBack = false;
    }

    // Update is called once per frame
    void Update()
    {
        //Debug.Log(gameCamera.transform.position.x + ", " + gameCamera.transform.position.y + ", " + gameCamera.transform.position.z);
        //Debug.Log(gameCamera.transform.rotation.eulerAngles.x + ", " + gameCamera.transform.rotation.eulerAngles.y + ", " + gameCamera.transform.rotation.eulerAngles.z);
        if (cameraPlay)
        {
            WikiButton.gameObject.SetActive(false);
            SettingsButton.gameObject.SetActive(false);

            if (gameCamera.transform.position.x > -50)
            {
                gameCamera.transform.position =
                    new Vector3(gameCamera.transform.position.x - 0.16f, gameCamera.transform.position.y + 0.12f, gameCamera.transform.position.z);
                gameCamera.transform.eulerAngles =
                    new Vector3(gameCamera.transform.eulerAngles.x + 0.08f, gameCamera.transform.eulerAngles.y, gameCamera.transform.eulerAngles.z);
            }
            else
            {
                cameraPlay = false;
                BackButton.gameObject.SetActive(true);
                TerrainSelections.gameObject.SetActive(true);
            }
        }

        if (cameraBack)
        {
            if (gameCamera.transform.position.x < -29.3)
            {
                BackButton.gameObject.SetActive(false);

                gameCamera.transform.position =
                    new Vector3(gameCamera.transform.position.x + 0.24f, gameCamera.transform.position.y - 0.18f, gameCamera.transform.position.z);
                gameCamera.transform.eulerAngles =
                    new Vector3(gameCamera.transform.eulerAngles.x - 0.12f, gameCamera.transform.eulerAngles.y, gameCamera.transform.eulerAngles.z);
            }
            else
            {
                cameraBack = false;

                PlayButton.gameObject.SetActive(true);
                WikiButton.gameObject.SetActive(true);
                SettingsButton.gameObject.SetActive(true);
            }

        }


    }

    public void Play()
    {
        cameraPlay = true;
        PlayButton.gameObject.SetActive(false);
    }

    public void Back()
    {
        cameraBack = true;
        TerrainSelections.gameObject.SetActive(false);
    }

    public void OpenWiki()
    {
        WikiPanel.gameObject.SetActive(true);
        PlayButton.gameObject.SetActive(false);
        WikiButton.gameObject.SetActive(false);
        SettingsButton.gameObject.SetActive(false);
        ClosePanelButton.gameObject.SetActive(true);
    }

    public void OpenSettings()
    {
        SettingsPanel.gameObject.SetActive(true);
        PlayButton.gameObject.SetActive(false);
        WikiButton.gameObject.SetActive(false);
        SettingsButton.gameObject.SetActive(false);
        ClosePanelButton.gameObject.SetActive(true);
    }

    public void ClosePanel()
    {
        WikiPanel.gameObject.SetActive(false);
        SettingsPanel.gameObject.SetActive(false);
        PlayButton.gameObject.SetActive(true);
        WikiButton.gameObject.SetActive(true);
        SettingsButton.gameObject.SetActive(true);
        ClosePanelButton.gameObject.SetActive(false);
    }

    public void SelectGrassLand()
    {
        BackButton.gameObject.SetActive(false);
        TerrainSelections.gameObject.SetActive(false);

        LoadingBar.gameObject.SetActive(true);

        // Load Scene
        SceneManager.LoadScene("Grassland");
    }

    public void SelectForest()
    {
        BackButton.gameObject.SetActive(false);
        TerrainSelections.gameObject.SetActive(false);

        LoadingBar.gameObject.SetActive(true);

        // Load Scene
        SceneManager.LoadScene("Forest");
    }

    public void SelectIsland()
    {
        BackButton.gameObject.SetActive(false);
        TerrainSelections.gameObject.SetActive(false);

        LoadingBar.gameObject.SetActive(true);

        // Load Scene
        SceneManager.LoadScene("Island");
    }



}
