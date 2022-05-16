async def apply(postgres, **_):
    tags = await postgres.fetch("SELECT * FROM bot_list_tags")
    for tag in tags:
        print(f"INSERT INTO bot_list_tags VALUES ('{tag['id']}', '{tag['icon']}');")
