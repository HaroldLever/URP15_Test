using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class HeadBoneMatrix : MonoBehaviour
{
    public GameObject headBone;
    public Material material;
    private Matrix4x4 faceWorldToLocal;

    void Update()
    {
        if(headBone == null){return;}
        if(material == null){return;}

        faceWorldToLocal = headBone.transform.worldToLocalMatrix;
        material.SetMatrix("_FaceWorldToLocal", faceWorldToLocal);
    }
}
