using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

[ExecuteAlways]
public class BTSkyCore : MonoBehaviour
{
    #region BTSkyObj
    [Header("BTSkyObj")]
    public Transform mainLight;
    public Transform mainCamera;

    public Transform atmoSphere;
    public Transform sun;
    public Transform moon;
    public Transform cloud_1;
    public Transform cloud_2;
    public Transform cloud_3;
    #endregion


    #region Time
    [Header("Time")]
    [Range(0, 60)]
    public int seconds = 0;
    [Range(0, 60)]
    public int minutes = 0;
    [Range(0, 24)]
    public int hours = 12;

    public float cycleLengthInMinutes = 1.0f;           //一天中实际的分钟数

    [Range(0, 1)]
    public float dayLengthRate = 0.5f;                  //(运行时)白天所占一整天真实时间的百分比

    private float timeRate = 0f;                        //当前时刻在一天中所占百分比

    [HideInInspector]
    public float internalHour;                          //(运行时)游戏内(当前时间)的小时表示
    [HideInInspector]
    public float hourTime;                              //(运行时)时间增量(deltimeTime)
    #endregion


    #region Fog
    [Header("Fog")]
    public bool fog = true;
    public FogMode fogMode = FogMode.Linear;
    public Gradient fogColor = new Gradient();
    public AnimationCurve fogDensity = new AnimationCurve();
    public float fogStartDistance = 40f;
    public float fogEndDistance = 400f;
    #endregion

    #region Light
    [Header("Light")]
    //public Transform mainLight1;
    public Gradient mainLightColor = new Gradient();
    public AnimationCurve mainLightIntensity = new AnimationCurve();
    [Range(0, 60)]
    public float shadowAngleBias = 20f;

    private Vector3 lightDirection = new Vector3();
    //private Quaternion mainLightRotation = new Quaternion();    //主光相对于当前天空球的局部旋转角度
    #endregion


    #region AtmoSphere
    [Header("AtmoSphere")]      //Atmosphere
    public Vector3 skyWorldUpDir = new Vector3();
    public Gradient topFrontColor = new Gradient();
    public Gradient topBackColor = new Gradient();
    public Gradient bottomFrontColor = new Gradient();
    public Gradient bottomBackColor = new Gradient();
    //[Range(0,1)]
    public AnimationCurve skyFrontAndBackBlendFactor = new AnimationCurve();
    //[Range(0, 1)]
    public AnimationCurve bottomColorHeight = new AnimationCurve();
    public Gradient horizonHaloColor = new Gradient();
    //[Range(0, 3)]
    public AnimationCurve horizonHaloIntensity = new AnimationCurve();
    //[Range(0, 1)]
    public AnimationCurve horizonHaloHeight = new AnimationCurve(); 

    [Header("Stars")]
    [Range(0, 5)]
    public float starsScintillation = 0.7f;
    [Range(0,1)]
    public float starsDensity = 0.75f;
    public AnimationCurve starBrightness = new AnimationCurve();

    //
    private Vector3 skyCenterWorldPos = new Vector3();      //运行时动态天空中心(主摄像机)的世界坐标
    #endregion


    #region Sun
    [Header("Sun")]
    [Range(100,1000)]
    public float sunSizeScale = 400f;
    public Gradient sunColor = new Gradient(); 
    [Range(0,1)]
    public float sunBrightness = 1.0f;
    [Range(0, 1)]
    public float sunRimLightRadius = 0.8f;                      //[Range(0,1)]边缘到内部梯度距离，做云边缘的亮度过渡
    [Range(0, 10000)]
    public float sunHaloSize = 1000f;  
    public Gradient sunHaloColor = new Gradient();
    [Range(0, 1)]
    public float sunHaloInstensity = 0.5f;  

    [Range(0,1)]
    public float sunSharpness = 0.49688f;              
    #endregion


    #region Moon
    [Header("Moon")]            //Moon
    [Range(100, 1000)]
    public float moonSizeScale = 200f;
    [Range(0,1)]
    public float moonGlowSize = 0.18814f;               //月亮的光圈大小
    public Gradient moonColor = new Gradient();         
    [Range(0,10)]
    public float moonBrightness = 3.3f;                 
    [Range(0,1)]
    public float moonGlowIntensity = 0.2f;              
    [Range(0, 1)]
    public float moonLunarPhase = 0.50f;                  //月相
    #endregion

    #region SunAndMoonTrack
    private CinemachineDollyCart sunDollyCart;
    private CinemachineDollyCart moonDollyCart;
    #endregion

    #region Clouds
    [Header("Clouds")]          //Clouds
    [Range(0, 1)]
    public float rotationSpeed = 0f;
    public Gradient cloudLightFrontColor = new Gradient();  //Sun:C:0.59731,0.74313,0.82224   152.3,189,209
    public Gradient cloudLightBackColor = new Gradient();   //Sun:C:0.56614,0.78056,0.9446    144,199,241
    public Gradient cloudDarkFrontColor = new Gradient();   //Sun:C:0.08944,0.35576,0.56966   23,91,145
    public Gradient cloudDarkBackColor = new Gradient();    //Sun:C:0.02257,0.23783,0.45227   5.8,61,115
    [Range(0,1)]
    public float cloudFrontAndBackBlendFactor = 0.1f;       //Sun:C:0.0881
    [Range(0, 1)]
    public float cloudCoverage = 0.11f;                     //Sun:C:0.11  [Range(0,1)]云的覆盖率
    [Range(0,1)]
    public float cloudSunBrightenIntensity = 0.8f;          //Sun:C:0.8299
    public AnimationCurve cloudElapsedTime = new AnimationCurve();                    //Sun:C:29.77093
    public AnimationCurve cloudAgePercent = new AnimationCurve();                    //Sun:C:1.00     //Dynamic

    [Header("Clouds Particle")]
    public Vector2 atlasTiles = new Vector2(2.0f, 4.0f);


    //[Header("Clouds Layer")] 
    //public Vector2 cloudDirection = new Vector3();
    //[Range(0, 1)]
    //public float cloudHeight = 0.1f;
    //[Range(0, 1)]
    //public float cloudTiling = 0.8f;
    //[Range(0,1)]
    //public float cloudOpacity = 1.0f;
    //public Vector2 cloudSmoothness = new Vector2();
    //[Range(0, 20)]
    //public float cloudWispsElapsedTime = 8f;
    //[Range(0, 1)]
    //public float cloudWispsCoverage = 1.0f;
    //[Range(0, 1)]
    //public float cloudWispsOpacity = 0.2f;

    #endregion


    // Start is called before the first frame update
    void Start()
    {
        
    }

    void OnEnable()
    {
        SetTime();
        InitSunAndMoonTrack();
    }

    // Update is called once per frame
    void Update() 
    {
        UpdateTime();
        CaculateCurrentTimeRate();

        UpdateSunAndMoon();

        UpdateMainLight();
        //SetMainLightDirection();

        UpdateFogAttribute();
        UpdateCloudAttribute();
        
        UpdateSkyShaderVariables();
    }

    //初始化太阳月亮运动轨道
    private void InitSunAndMoonTrack()
    {
        if (sun != null)
        {
            sunDollyCart = sun.GetComponent<CinemachineDollyCart>();
            if (sunDollyCart != null)
                sunDollyCart.m_Speed = 0f;
        }
        if (moon != null)
        {
            moonDollyCart = moon.GetComponent<CinemachineDollyCart>();
            if (moonDollyCart != null)
                moonDollyCart.m_Speed = 0f;
        }
    }

    private void UpdateCloudAttribute()
    {
        if (cloud_1)
            cloud_1.transform.Rotate(new Vector3(0, 0.2f * rotationSpeed, 0));
        if (cloud_2)
            cloud_2.transform.Rotate(new Vector3(0, 0.2f * rotationSpeed, 0));
        if (cloud_3)
            cloud_3.transform.Rotate(new Vector3(0, 0.2f * rotationSpeed, 0));
    }

    private void UpdateFogAttribute()
    {
        RenderSettings.fog = fog;
        RenderSettings.fogMode = fogMode;
        RenderSettings.fogColor = fogColor.Evaluate(timeRate);
        RenderSettings.fogDensity = fogDensity.Evaluate(timeRate);
        RenderSettings.fogStartDistance = fogStartDistance;
        RenderSettings.fogEndDistance = fogEndDistance;
    }

    public void SetTime()
    {
        internalHour = hours + (minutes * 0.0166667f) + (seconds * 0.000277778f);
    }

    //计算当前时刻所占百分比
    private void CaculateCurrentTimeRate()
    {
        int curSecondsTime = seconds + minutes * 60 + hours * 3600;
        timeRate = Mathf.Clamp01(curSecondsTime / 86400f);
    }

    //在运行模式下自动跟新时间
    public void UpdateTime()
    {
        if (Application.isPlaying)
        {
            float tDay = 0f, tNight = 0f;

            //游戏内白天时间
            tDay = (12.0f / 60.0f) / (cycleLengthInMinutes * dayLengthRate);
            //游戏内晚上时间
            tNight = (12.0f / 60.0f) / (cycleLengthInMinutes * (1f - dayLengthRate));

            //hourTime = tDay * Time.deltaTime;
            //时间增量
            hourTime = ((hours >= 6 && hours < 18) ? tDay : tNight) * Time.deltaTime;

            //目前只用自定义的时间
            internalHour += hourTime;

            UpdateGameTime();
        }
    }

    //更新太阳和月亮在轨道上的Transform
    private void UpdateSunAndMoon()
    {
        if (sunDollyCart && sunDollyCart.m_Path)
            sunDollyCart.m_Position = sunDollyCart.m_Path.PathLength * timeRate;
        if (moonDollyCart && moonDollyCart.m_Path)
            moonDollyCart.m_Position = moonDollyCart.m_Path.PathLength * ((timeRate + 0.5f) - (float)Mathf.Floor(timeRate + 0.5f));

        //更新旋转信息(始终看向天空球中心)和大小
        if (sun)
        {
            sun.GetChild(0).LookAt(skyCenterWorldPos);
            sun.GetChild(0).localScale = new Vector3(sunSizeScale, sunSizeScale, sunSizeScale);
        }
        if (moon)
        {
            moon.GetChild(0).LookAt(skyCenterWorldPos);
            moon.GetChild(0).localScale = new Vector3(moonSizeScale, moonSizeScale, moonSizeScale);
        }
    }

    //更新(游戏内)时间
    private void UpdateGameTime()
    {
        internalHour = (internalHour >= 24f) ? (internalHour - 24f) : internalHour;
        internalHour = (internalHour < 0f) ? 24f + internalHour : internalHour;

        hours = (int)internalHour;
        float inHours = (internalHour - hours);
        minutes = (int)(inHours * 60f);
        inHours -= minutes * 0.0166667f;
        seconds = (int)(inHours * 3600f);
    }

    private void UpdateMainLight()
    {
        if (mainLight == null)
            return;

        Light light = mainLight.GetComponent<Light>();
        light.color = mainLightColor.Evaluate(timeRate);
        light.intensity = mainLightIntensity.Evaluate(timeRate);

        light.transform.rotation = (hours > 5 && hours < 18) ? sun.GetChild(0).rotation : moon.GetChild(0).rotation;
    }

    //Shader.Set... is setting Global properties
    //skyMat.Set... is setting material instance properties
    private void UpdateSkyShaderVariables()
    {
        Shader.SetGlobalVector("_ES_SkyCenterWorldPos", skyCenterWorldPos);
        Shader.SetGlobalVector("_ES_SkyWorldUpDir", skyWorldUpDir);

        Shader.SetGlobalVector("_ES_LightDirection", lightDirection);

        Shader.SetGlobalColor("_ES_TopFrontColor", topFrontColor.Evaluate(timeRate));
        Shader.SetGlobalColor("_ES_TopBackColor", topBackColor.Evaluate(timeRate));
        Shader.SetGlobalColor("_ES_BottomFrontColor", bottomFrontColor.Evaluate(timeRate));
        Shader.SetGlobalColor("_ES_BottomBackColor", bottomBackColor.Evaluate(timeRate));
        Shader.SetGlobalFloat("_ES_SkyFrontAndBackBlendFactor", skyFrontAndBackBlendFactor.Evaluate(timeRate));
        Shader.SetGlobalFloat("_ES_BottomColorHeight", bottomColorHeight.Evaluate(timeRate));
        Shader.SetGlobalColor("_ES_HorizonHaloColor", horizonHaloColor.Evaluate(timeRate));
        Shader.SetGlobalFloat("_ES_HorizonHaloIntensity", horizonHaloIntensity.Evaluate(timeRate));
        Shader.SetGlobalFloat("_ES_HorizonHaloHeight", horizonHaloHeight.Evaluate(timeRate));

        if(sun)
            //Shader.SetGlobalVector("_ES_SunDirection", sun.GetChild(0).transform.forward);                   //Moon:M (-0.03856,-0.9555,-0.29247)
            Shader.SetGlobalVector("_ES_SunDirection", -sun.GetChild(0).transform.forward);
        Shader.SetGlobalColor("_ES_SunColor", sunColor.Evaluate(timeRate));
        Shader.SetGlobalFloat("_ES_SunBrightness", sunBrightness);
        Shader.SetGlobalFloat("_ES_SunRimLightRadius", sunRimLightRadius);
        Shader.SetGlobalFloat("_ES_SunHaloSize", sunHaloSize);
        Shader.SetGlobalColor("_ES_SunHaloColor", sunHaloColor.Evaluate(timeRate));
        Shader.SetGlobalFloat("_ES_SunHaloIntensity", sunHaloInstensity);
        Shader.SetGlobalFloat("_ES_SunSharpness", sunSharpness);
        
        if(moon)
            //Shader.SetGlobalVector("_ES_MoonDirection", moon.GetChild(0).transform.forward);
            Shader.SetGlobalVector("_ES_MoonDirection", -moon.GetChild(0).transform.forward);
        Shader.SetGlobalFloat("_ES_MoonSize", moonGlowSize);
        Shader.SetGlobalColor("_ES_MoonColor", moonColor.Evaluate(timeRate));                       //Moon:M (0.29669,0.64985,1.00) 76,166,255
        Shader.SetGlobalFloat("_ES_MoonBrightness", moonBrightness);
        Shader.SetGlobalFloat("_ES_MoonGlowIntensity", moonGlowIntensity);
        Shader.SetGlobalFloat("_ES_MoonLunarPhase", moonLunarPhase);

        Shader.SetGlobalVector("_AtlasTiles", atlasTiles);
        Shader.SetGlobalFloat("_ES_CloudElapsedTime", cloudElapsedTime.Evaluate(timeRate));
        //Shader.SetGlobalFloat("_ES_CloudElapsedTime", 0.0f);
       
        Shader.SetGlobalColor("_ES_CloudLightFrontColor", cloudLightFrontColor.Evaluate(timeRate));
        Shader.SetGlobalColor("_ES_CloudLightBackColor", cloudLightBackColor.Evaluate(timeRate));
        Shader.SetGlobalColor("_ES_CloudDarkFrontColor", cloudDarkFrontColor.Evaluate(timeRate));
        Shader.SetGlobalColor("_ES_CloudDarkBackColor", cloudDarkBackColor.Evaluate(timeRate));
        Shader.SetGlobalFloat("_ES_CloudFrontAndBackBlendFactor", cloudFrontAndBackBlendFactor);   
        Shader.SetGlobalFloat("_ES_CloudCoverage", cloudCoverage);        
        Shader.SetGlobalFloat("_ES_CloudAgePercent", cloudAgePercent.Evaluate(timeRate));
        Shader.SetGlobalFloat("_ES_CloudSunBrightenIntensity", cloudSunBrightenIntensity);


        //Shader.SetGlobalVector("_ES_CloudDirection", cloudDirection);
        //Shader.SetGlobalFloat("_ES_CloudHeight", cloudHeight);
        //Shader.SetGlobalFloat("_ES_CloudTiling", cloudTiling);
        //Shader.SetGlobalFloat("_ES_CloudOpacity", cloudOpacity);
        //Shader.SetGlobalVector("_ES_CloudSmoothness", cloudSmoothness);
        //Shader.SetGlobalFloat("_ES_CloudWispsElapsedTime", cloudWispsElapsedTime);
        //Shader.SetGlobalFloat("_ES_CloudWispsCoverage", cloudWispsCoverage);
        //Shader.SetGlobalFloat("_ES_CloudWispsOpacity", cloudWispsOpacity);

        Shader.SetGlobalFloat("_ES_StarsScintillation", starsScintillation);
        Shader.SetGlobalFloat("_ES_StarsBrightness", starBrightness.Evaluate(timeRate) * 100f);
        Shader.SetGlobalFloat("_ES_StarsDensity", starsDensity);
    }
}
