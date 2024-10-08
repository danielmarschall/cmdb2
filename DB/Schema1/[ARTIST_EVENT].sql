CREATE TABLE [dbo].[ARTIST_EVENT](
	[ID] [uniqueidentifier] NOT NULL,
	[ARTIST_ID] [uniqueidentifier] NOT NULL,
	[DATE] [datetime] NOT NULL,
	[STATE] [nvarchar](20) NOT NULL,
	[ANNOTATION] [nvarchar](250) NULL,
	[LEGACY_ID] [int] NULL,
 CONSTRAINT [PK_ARTIST_EVENT] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];

ALTER TABLE [dbo].[ARTIST_EVENT] ADD  CONSTRAINT [DF_ARTIST_EVENT_ID]  DEFAULT (newid()) FOR [ID];

ALTER TABLE [dbo].[ARTIST_EVENT]  WITH CHECK ADD  CONSTRAINT [FK_ARTIST_EVENTS_ARTIST] FOREIGN KEY([ARTIST_ID])
REFERENCES [dbo].[ARTIST] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE [dbo].[ARTIST_EVENT] CHECK CONSTRAINT [FK_ARTIST_EVENTS_ARTIST];
