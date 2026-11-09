import asyncio
from playwright.async_api import async_playwright

async def extract_video_links():
    start_episode = 81
    num_episodes = 20
    links_output = []

    async with async_playwright() as p:
        # Use Playwright's native Chromium to avoid all Snap sandbox permission errors
        browser = await p.chromium.launch(
            headless=False,
            args=["--disable-blink-features=AutomationControlled"]
        )
        context = await browser.new_context()

        for ep in range(start_episode, start_episode + num_episodes):
            url = f"https://ristoanime.me/أنمي-بلاك-كلوفر-black-clover-الحلقة-{ep}/watch/"
            print(f"\n--- Processing Episode {ep} ---")
            
            page = await context.new_page()
            
            # Instantly kill and close any new ad tab or popup window the moment it tries to open
            page.on("popup", lambda popup: popup.close())
            
            captured_links = []

            def handle_request(request):
                req_url = request.url
                if any(ext in req_url.lower() for ext in ['.m3u8', '.mp4', '.ts', 'googlevideo', 'mp4upload', 'vidcdn']):
                    if req_url not in captured_links:
                        captured_links.append(req_url)

            page.on("request", handle_request)

            try:
                await page.goto(url, timeout=60000)
                print(f"-> Episode {ep} opened. Please click play manually...")
                
                # Wait up to 30 seconds for you to hit play and capture the .m3u8 link
                for _ in range(30):
                    await asyncio.sleep(1)
                    if any('m3u8' in l.lower() for l in captured_links):
                        print("-> Stream link detected! Capturing...")
                        await asyncio.sleep(2)
                        break
                
                if captured_links:
                    master_links = [l for l in captured_links if 'master.m3u8' in l or '.m3u8' in l]
                    target_link = master_links[0] if master_links else captured_links[-1]
                    
                    # Save episode header and link
                    links_output.append(f"# Episode {ep}\n")
                    links_output.append(target_link + "\n\n")
                    print(f"Successfully captured link for Episode {ep}")
                else:
                    links_output.append(f"# Episode {ep}: Link not found\n\n")
                    print(f"Warning: No video link captured for Episode {ep}")

            except Exception as e:
                print(f"Error on Episode {ep}: {e}")
                links_output.append(f"# Episode {ep}: ERROR - {str(e)}\n\n")
            finally:
                await page.close()

        with open("black_clover_links.txt", "w", encoding="utf-8") as f:
            f.writelines(links_output)
            
        print("\nAll done! Links successfully saved to 'black_clover_links.txt'.")
        await browser.close()

if __name__ == "__main__":
    asyncio.run(extract_video_links())