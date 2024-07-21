using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using UnityEngine;
using UnityEditor.AssetImporters;


[ScriptedImporter(1, "kra")]
public class KraImporter : ScriptedImporter
{
    // public TextureFormat textureFormat;
    public TextureWrapMode wrapMode = TextureWrapMode.Repeat;
    public FilterMode filterMode = FilterMode.Bilinear;
    public int anisoLevel = 1;


    public override void OnImportAsset(AssetImportContext ctx)
    {
        var path = ctx.assetPath;

        using (ZipArchive archive = ZipFile.OpenRead(path))
        {
            var mergedImageEntry = archive.GetEntry("mergedimage.png");

            if (mergedImageEntry == null)
            {
                Debug.LogWarning($"{path} 不含 mergedimage.png");
            }
            else
            {
                using (DeflateStream stream = (DeflateStream)mergedImageEntry.Open())
                {
                    int byteLength = (int)stream.BaseStream.Length;
                    byte[] imageByte = new byte[byteLength];
                    stream.Read(imageByte, 0, byteLength);
                    
                    Texture2D texture = new Texture2D(1, 1);
                    ImageConversion.LoadImage(texture, imageByte);

                    texture.wrapMode = wrapMode;
                    texture.filterMode = filterMode;
                    texture.anisoLevel = anisoLevel;
                    // texture.Apply();

                    ctx.AddObjectToAsset("merged image", texture);
                    ctx.SetMainObject(texture);
                }
            }
        }
    }
}
