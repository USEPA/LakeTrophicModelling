
wsa9<-readOGR(".","wsa9_low48")
wsa9@data$id <- rownames(wsa9@data)
wsa9_f <- fortify(wsa9, region="WSA_9")
names(wsa9_f)[which(names(wsa9_f)=="id")] = "WSA_9"
wsa9_df = plyr::join(wsa9_f, wsa9@data, by="WSA_9")


a<-ggplot(wsa9_df, aes(long,lat,group=group,fill=id)) +
  geom_polygon(data=subset(wsa9_df,WSA_9!="WMT")) +
  geom_polygon(data=subset(wsa9_df,WSA_9=="WMT")) +
  geom_path(color="white") +
  coord_equal() +
  coord_map("albers", lat2 = 45.5, lat1 = 29.5)+
  theme(panel.background = element_rect(fill="white"), panel.grid = element_blank(),
        panel.border = element_blank(), #legend.position = "none",
        axis.text = element_blank(),axis.ticks = element_blank()) +
  ylab("") +
  xlab("")
a
