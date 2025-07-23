using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MeetlyOmni.Api.Migrations
{
    /// <inheritdoc />
    public partial class MemberUuidMigrationFixed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Drop foreign key constraints first
            migrationBuilder.DropForeignKey(
                name: "FK_GameRecord_Members_MemberId",
                table: "GameRecord");

            migrationBuilder.DropForeignKey(
                name: "FK_MemberActivityLogs_Members_MemberId",
                table: "MemberActivityLogs");

            migrationBuilder.DropForeignKey(
                name: "FK_RaffleTickets_Members_MemberId",
                table: "RaffleTickets");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Members",
                table: "Members");

            // Drop the old string MemberId column
            migrationBuilder.DropColumn(
                name: "MemberId",
                table: "Members");

            // Rename indexes to match new naming convention
            migrationBuilder.RenameIndex(
                name: "IX_Member_OrgId_LocalMemberNumber",
                table: "Members",
                newName: "UK_Member_Org_LocalNumber");

            migrationBuilder.RenameIndex(
                name: "IX_Member_OrgId_Email",
                table: "Members",
                newName: "UK_Member_Org_Email");

            // Add new UUID primary key to Members
            migrationBuilder.AddColumn<Guid>(
                name: "Id",
                table: "Members",
                type: "uuid",
                nullable: false,
                defaultValueSql: "gen_random_uuid()");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Members",
                table: "Members",
                column: "Id");

            // Use raw SQL to handle PostgreSQL string to UUID conversion
            // This will clear existing data and regenerate UUIDs
            migrationBuilder.Sql(@"
                -- Clear existing data from related tables since we can't preserve relationships
                TRUNCATE TABLE ""RaffleTickets"" CASCADE;
                TRUNCATE TABLE ""MemberActivityLogs"" CASCADE;
                TRUNCATE TABLE ""GameRecord"" CASCADE;
                TRUNCATE TABLE ""Members"" CASCADE;
            ");

            // Convert foreign key columns to UUID type
            migrationBuilder.Sql(@"
                ALTER TABLE ""RaffleTickets"" ALTER COLUMN ""MemberId"" TYPE uuid USING gen_random_uuid();
                ALTER TABLE ""MemberActivityLogs"" ALTER COLUMN ""MemberId"" TYPE uuid USING gen_random_uuid();
                ALTER TABLE ""GameRecord"" ALTER COLUMN ""MemberId"" TYPE uuid USING gen_random_uuid();
            ");

            // Recreate foreign key relationships
            migrationBuilder.AddForeignKey(
                name: "FK_Game_Members_CreatedBy",
                table: "Game",
                column: "CreatedBy",
                principalTable: "Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_GameRecord_Members_MemberId",
                table: "GameRecord",
                column: "MemberId",
                principalTable: "Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MemberActivityLogs_Members_MemberId",
                table: "MemberActivityLogs",
                column: "MemberId",
                principalTable: "Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_RaffleTickets_Members_MemberId",
                table: "RaffleTickets",
                column: "MemberId",
                principalTable: "Members",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Drop foreign key constraints
            migrationBuilder.DropForeignKey(
                name: "FK_Game_Members_CreatedBy",
                table: "Game");

            migrationBuilder.DropForeignKey(
                name: "FK_GameRecord_Members_MemberId",
                table: "GameRecord");

            migrationBuilder.DropForeignKey(
                name: "FK_MemberActivityLogs_Members_MemberId",
                table: "MemberActivityLogs");

            migrationBuilder.DropForeignKey(
                name: "FK_RaffleTickets_Members_MemberId",
                table: "RaffleTickets");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Members",
                table: "Members");

            // Drop the UUID column
            migrationBuilder.DropColumn(
                name: "Id",
                table: "Members");

            // Rename indexes back
            migrationBuilder.RenameIndex(
                name: "UK_Member_Org_LocalNumber",
                table: "Members",
                newName: "IX_Member_OrgId_LocalMemberNumber");

            migrationBuilder.RenameIndex(
                name: "UK_Member_Org_Email",
                table: "Members",
                newName: "IX_Member_OrgId_Email");

            // Restore string columns
            migrationBuilder.AddColumn<string>(
                name: "MemberId",
                table: "Members",
                type: "character varying(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            // Convert foreign key columns back to string
            migrationBuilder.Sql(@"
                ALTER TABLE ""RaffleTickets"" ALTER COLUMN ""MemberId"" TYPE character varying(50) USING ''::character varying(50);
                ALTER TABLE ""MemberActivityLogs"" ALTER COLUMN ""MemberId"" TYPE character varying(50) USING ''::character varying(50);
                ALTER TABLE ""GameRecord"" ALTER COLUMN ""MemberId"" TYPE character varying(50) USING ''::character varying(50);
            ");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Members",
                table: "Members",
                column: "MemberId");

            // Recreate old foreign key relationships
            migrationBuilder.AddForeignKey(
                name: "FK_GameRecord_Members_MemberId",
                table: "GameRecord",
                column: "MemberId",
                principalTable: "Members",
                principalColumn: "MemberId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_MemberActivityLogs_Members_MemberId",
                table: "MemberActivityLogs",
                column: "MemberId",
                principalTable: "Members",
                principalColumn: "MemberId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_RaffleTickets_Members_MemberId",
                table: "RaffleTickets",
                column: "MemberId",
                principalTable: "Members",
                principalColumn: "MemberId",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
