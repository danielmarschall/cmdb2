CREATE TABLE [dbo].[COMMISSION](
	[ID] [uniqueidentifier] NOT NULL,
	[ARTIST_ID] [uniqueidentifier] NULL,
	[NAME] [nvarchar](100) NULL,
	[LEGACY_ID] [int] NULL,
	[FOLDER] [nvarchar](200) NULL,
 CONSTRAINT [PK_COMMISSION] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];

ALTER TABLE [dbo].[COMMISSION] ADD  CONSTRAINT [DF_COMMISSION_ID]  DEFAULT (newid()) FOR [ID];

ALTER TABLE [dbo].[COMMISSION]  WITH CHECK ADD  CONSTRAINT [FK_COMMISSION_ARTIST] FOREIGN KEY([ARTIST_ID])
REFERENCES [dbo].[ARTIST] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE [dbo].[COMMISSION] CHECK CONSTRAINT [FK_COMMISSION_ARTIST];