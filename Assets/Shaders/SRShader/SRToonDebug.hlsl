#ifdef _BASEMAP_DEBUG_RGB
return half4(base.rgb, 1.0);
#endif
#ifdef _BASEMAP_DEBUG_A
return half4(base.aaa, 1.0);
#endif
#ifdef _BASEMAP_DEBUG_RGBA
return base;
#endif

#ifdef _LIGHTMAP_DEBUG_R
return half4(lightMap.rrr, 1.0);
#endif
#ifdef _LIGHTMAP_DEBUG_G
return half4(lightMap.ggg, 1.0);
#endif
#ifdef _LIGHTMAP_DEBUG_B
return half4(lightMap.bbb, 1.0);
#endif
#ifdef _LIGHTMAP_DEBUG_A
return half4(lightMap.aaa, 1.0);
#endif