CREATE TABLE [dbo].[BACKUP](
	[BAK_ID] [int] NOT NULL,
	[BAK_DATE] [datetime] NOT NULL,
	[BAK_LINES] [int] NOT NULL,
	[CHECKSUM] [char](64) NULL,
	[ANNOTATION] [nvarchar](250) NULL,
 CONSTRAINT [PK_BACKUP] PRIMARY KEY CLUSTERED
(
	[BAK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY];