(function () {
	const neutralItems = FindDotaHudElement("TeamNeutralItemsTierList");
	neutralItems.GetParent().style.overflow = "squish scroll";
	neutralItems.Children().forEach((neutralTier) => {
		const panel = neutralTier.GetChild(1);
		panel.style.flowChildren = "right-wrap";
	});
	const neutralItemsLabel = FindDotaHudElement("GridNeutralItems").GetParent();
	neutralItemsLabel.style.overflow = "squish scroll";

	const side_stats = FindDotaHudElement("stackable_side_panels");
	if (side_stats) side_stats.style.marginTop = "60px";

	const game_info_button = FindDotaHudElement("GameInfoButton");
	if (game_info_button) game_info_button.style.marginTop = "45px";
})();
