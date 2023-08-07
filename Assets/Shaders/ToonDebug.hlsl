#ifdef _BASEMAP_DEBUG_RGB
return half4(base.rgb, 1.0);
#endif
#ifdef _BASEMAP_DEBUG_A
return half4(base.aaa, 1.0);
#endif
#ifdef _BASEMAP_DEBUG_RGBA
return base;
#endif

#ifdef _NORMALMAP_DEBUG_R
return half4(nor.rrr, 1.0);
#endif
#ifdef _NORMALMAP_DEBUG_G
return half4(nor.ggg, 1.0);
#endif
#ifdef _NORMALMAP_DEBUG_B
return half4(nor.bbb, 1.0);
#endif
#ifdef _NORMALMAP_DEBUG_A
return half4(nor.aaa, 1.0);
#endif
#ifdef _NORMALMAP_DEBUG_RGB
return half4(nor.rgb, 1.0);
#endif

#ifdef _MASKMAP_DEBUG_R
return half4(mask.rrr, 1.0);
#endif
#ifdef _MASKMAP_DEBUG_G
return half4(mask.ggg, 1.0);
#endif
#ifdef _MASKMAP_DEBUG_B
return half4(mask.bbb, 1.0);
#endif
#ifdef _MASKMAP_DEBUG_A
return half4(mask.aaa, 1.0);
#endif

#ifdef _PROPERTYMAP_DEBUG_RGB
return half4(prop.rgb, 1.0);
#endif
#ifdef _PROPERTYMAP_DEBUG_A
return half4(prop.aaa, 1.0);
#endif
#ifdef _PROPERTYMAP_DEBUG_RGBA
return prop;
#endif