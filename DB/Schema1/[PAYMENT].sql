CREATE TABLE [dbo].[PAYMENT](
	[ID] [uniqueidentifier] NOT NULL,
	[ARTIST_ID] [uniqueidentifier] NOT NULL,
	[DATE] [datetime] NOT NULL,
	[AMOUNT] [money] NOT NULL,
	[CURRENCY] [nvarchar](3) NOT NULL,
	[AMOUNT_LOCAL] [money] NULL,
	[AMOUNT_VERIFIED] [bit] NULL,
	[PAYPROV] [nvarchar](35) NULL,
	[ANNOTATION] [nvarchar](200) NULL,
 CONSTRAINT [PK_PAYMENT] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];

ALTER TABLE [dbo].[PAYMENT] ADD  CONSTRAINT [DF_PAYMENT_ID]  DEFAULT (newid()) FOR [ID];

ALTER TABLE [dbo].[PAYMENT]  WITH CHECK ADD  CONSTRAINT [FK_PAYMENT_ARTIST] FOREIGN KEY([ARTIST_ID])
REFERENCES [dbo].[ARTIST] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE [dbo].[PAYMENT] CHECK CONSTRAINT [FK_PAYMENT_ARTIST];
