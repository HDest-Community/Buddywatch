version "4.0"

class BuddyWatchHandler : StaticEventHandler
{
	private ui HUDFont MainFont;
	private ui int HealthBars[HDStatusBar.STB_BEATERSIZE * MAXPLAYERS];

	override void RenderOverlay(RenderEvent e)
	{
		if (AutomapActive || GameState != GS_LEVEL)
		{
			return;
		}

		MainFont = HUDFont.Create("SMALLFONT");

		int OriginalWidth = StatusBar.HorizontalResolution;
		int OriginalHeight = StatusBar.VerticalResolution;

		vector2 StartOffset = (-6, 3);
		for (int i = 0; i < MAXPLAYERS; ++i)
		{
			let plr = HDPlayerPawn(players[i].mo);
			if (!plr/* || StatusBar.CPlayer.mo == plr*/)
			{
				continue;
			}

			StatusBar.DrawString(MainFont, plr.player.GetUserName(), StartOffset, StatusBar.DI_SCREEN_RIGHT_TOP | StatusBar.DI_TEXT_ALIGN_RIGHT, scale: (0.75, 0.75));
			DrawHealthTicker(StatusBar, plr, (StartOffset.x - 8, StartOffset.y + 14), StatusBar.DI_SCREEN_RIGHT_TOP);
			StartOffset.y += 22;
		}
	}

	// [Ace] Copy-pasted from HD.
	private ui void DrawHealthTicker(BaseStatusBar sb, HDPlayerPawn plr, vector2 drawpos, int flags)
	{
		Color sbcolour = plr.player.GetDisplayColor();
		int Extra = HDStatusBar.STB_BEATERSIZE * plr.PlayerNumber();
		if (!plr.beatcount)
		{
			for (int i = 0; i < HDStatusBar.STB_BEATERSIZE - 2; ++i)
			{
				HealthBars[Extra + i] = HealthBars[Extra + i + 2];
			}
			int err = max(0, ((100 - plr.health) >> 3));
			err = random[heart](0, err);
			HealthBars[Extra + (HDStatusBar.STB_BEATERSIZE - 2)] = clamp(18 - (plr.bloodloss >> 7) - (err >> 2), 1, 18);
			HealthBars[Extra + (HDStatusBar.STB_BEATERSIZE - 1)] = (plr.inpain ? random[heart](1, 7) : 1) + err + random[heart](0, plr.bloodpressure >> 3);
		}

		for (int i = 0; i < HDStatusBar.STB_BEATERSIZE; ++i)
		{
			int alf = (i & 1) ? 128 : 255;
			sb.Fill((plr.health > 70 ? color(alf, sbcolour.r, sbcolour.g, sbcolour.b) : plr.health > 33 ? color(alf, 240, 210, 10) : color(alf, 220, 0, 0)), drawpos.x + i - (HDStatusBar.STB_BEATERSIZE >> 2), drawpos.y - HealthBars[Extra + i] * 0.3, 0.8, HealthBars[Extra + i] * 0.6, flags | sb.DI_ITEM_CENTER | (plr.health > 70 ? sb.DI_TRANSLATABLE : 0));
		}
	}
}