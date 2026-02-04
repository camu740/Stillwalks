package com.stillwalks.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class StillwalksWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Total Essence
                val essence = widgetData.getString("total_essence", "0")
                setTextViewText(R.id.tv_total_essence, essence)
                
                // Journal Progress
                val journal = widgetData.getString("journal_progress", "0 / 0")
                setTextViewText(R.id.tv_journal_progress, journal)

                // Sanctuary 1
                val s1Name = widgetData.getString("s1_name", "Santuario Primordial")
                val s1Progress = widgetData.getInt("s1_progress", 0)
                val s1Color = widgetData.getLong("s1_color", 0xFFE040FB).toInt()
                val s1TitleColor = widgetData.getLong("s1_title_color", 0xFFE040FB).toInt()
                val s1Status = widgetData.getString("s1_status", "Sin orbe activo")
                
                setTextViewText(R.id.tv_sanctuary_1_name, s1Name)
                setTextViewText(R.id.tv_sanctuary_1_status, s1Status)
                // Usando ImageView + ClipDrawable
                setInt(R.id.iv_progress_sanctuary_1, "setImageLevel", s1Progress)
                setInt(R.id.iv_progress_sanctuary_1, "setColorFilter", s1Color)
                setTextColor(R.id.tv_sanctuary_1_name, s1TitleColor)
                setInt(R.id.iv_sanctuary_1_icon, "setColorFilter", s1TitleColor)
                
                // Sanctuary 2 (Checking visibility)
                val s2Visible = widgetData.getBoolean("s2_visible", false)
                setViewVisibility(R.id.layout_sanctuary_2, if (s2Visible) android.view.View.VISIBLE else android.view.View.GONE)
                
                if (s2Visible) {
                    val s2Name = widgetData.getString("s2_name", "Santuario Temporal")
                    val s2Progress = widgetData.getInt("s2_progress", 0)
                    val s2Color = widgetData.getLong("s2_color", 0xFF18FFFF).toInt()
                    val s2TitleColor = widgetData.getLong("s2_title_color", 0xFF18FFFF).toInt()
                    val s2Status = widgetData.getString("s2_status", "Sin orbe activo")
                    val s2IconType = widgetData.getString("s2_icon_type", "default")
                    
                    // Icon logic
                    val iconRes = when (s2IconType) {
                        "fast" -> R.drawable.ic_sanctuary_fast
                        "symbiosis" -> R.drawable.ic_sanctuary_symbiosis
                        else -> R.drawable.ic_sanctuary
                    }
                    setImageViewResource(R.id.iv_sanctuary_2_icon, iconRes)
                    
                    setTextViewText(R.id.tv_sanctuary_2_name, s2Name)
                    setTextViewText(R.id.tv_sanctuary_2_status, s2Status)
                    setInt(R.id.iv_progress_sanctuary_2, "setImageLevel", s2Progress)
                    setInt(R.id.iv_progress_sanctuary_2, "setColorFilter", s2Color)
                    setTextColor(R.id.tv_sanctuary_2_name, s2TitleColor)
                    setInt(R.id.iv_sanctuary_2_icon, "setColorFilter", s2TitleColor)
                }

                // Storage (Checking visibility)
                val storageVisible = widgetData.getBoolean("storage_visible", false)
                setViewVisibility(R.id.layout_storage, if (storageVisible) android.view.View.VISIBLE else android.view.View.GONE)
                
                if (storageVisible) {
                    val storageName = widgetData.getString("storage_name", "Almacén de Energía")
                    val storageProgress = widgetData.getInt("storage_progress", 0)
                    val storageColor = widgetData.getLong("storage_color", 0xFF448AFF).toInt()
                    val storageTitleColor = widgetData.getLong("storage_title_color", 0xFF448AFF).toInt()
                    val storageStatus = widgetData.getString("storage_status", "0 / 0")
                    
                    setTextViewText(R.id.tv_storage_name, storageName)
                    setTextViewText(R.id.tv_storage_status, storageStatus)
                    setInt(R.id.iv_progress_storage, "setImageLevel", storageProgress)
                    setInt(R.id.iv_progress_storage, "setColorFilter", storageColor)
                    setTextColor(R.id.tv_storage_name, storageTitleColor)
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
