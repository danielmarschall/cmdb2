CREATE TABLE [dbo].[QUOTE](
	[ID] [uniqueidentifier] NOT NULL,
	[EVENT_ID] [uniqueidentifier] NOT NULL,
	[NO] [int] NOT NULL,
	[AMOUNT] [money] NOT NULL,
	[CURRENCY] [nvarchar](3) NOT NULL,
	[AMOUNT_LOCAL] [money] NULL,
	[IS_FREE] [bit] NULL,
	[DESCRIPTION] [nvarchar](100) NULL,
	[LEGACY_ID] [int] NULL,
 CONSTRAINT [PK_vw_QUOTE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY];

ALTER TABLE [dbo].[QUOTE] ADD  CONSTRAINT [DF_vw_QUOTE_ID]  DEFAULT (newid()) FOR [ID];

ALTER TABLE [dbo].[QUOTE]  WITH CHECK ADD  CONSTRAINT [FK_QUOTE_EVENT] FOREIGN KEY([EVENT_ID])
REFERENCES [dbo].[COMMISSION_EVENT] ([ID])
ON UPDATE CASCADE
ON DELETE CASCADE;

ALTER TABLE [dbo].[QUOTE] CHECK CONSTRAINT [FK_QUOTE_EVENT];