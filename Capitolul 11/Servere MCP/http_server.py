import os
from mcp.server.transport_security import TransportSecuritySettings
from pgsql_mcp_server.app import mcp 

from mcp.server.fastmcp import Context
from sqlmodel import text
from tabulate import tabulate
 
mcp.settings.host = os.getenv("MCP_HOST", "0.0.0.0")
mcp.settings.port = int(os.getenv("MCP_PORT", "8000"))
mcp.settings.streamable_http_path = "/mcp"
mcp.settings.stateless_http = True
 
mcp.settings.transport_security = TransportSecuritySettings(
    enable_dns_rebinding_protection=True,
    allowed_hosts=["mcp:8000", "localhost:*", "127.0.0.1:*"],
    allowed_origins=["*"],
)

@mcp.tool()
async def top_customers(ctx: Context, limit: int = 5, status: str = "delivered") -> str:
    """Top clienti dupa venit total.
 
    Args:
        limit: cati clienti sa returneze (implicit 5).
        status: statusul comenzilor luate in calcul (implicit 'delivered').
    """
    engine = ctx.request_context.lifespan_context.engine
    sql = text(
        """
        SELECT c.full_name, c.country, c.loyalty_tier,
               count(*)                      AS orders,
               round(sum(o.total_amount), 2) AS revenue
        FROM orders o
        JOIN customers c USING (customer_id)
        WHERE o.status = :status
        GROUP BY c.customer_id, c.full_name, c.country, c.loyalty_tier
        ORDER BY revenue DESC
        LIMIT :limit
        """
    )
    async with engine.connect() as conn:
        rows = (await conn.execute(sql, {"status": status, "limit": limit})).fetchall()
 
    if not rows:
        return f"Niciun client cu comenzi in statusul '{status}'."
    return tabulate(
        rows,
        headers=["client", "tara", "tier", "comenzi", "venit"],
        tablefmt="simple",
    )
 
if __name__ == "__main__":
    mcp.run(transport="streamable-http")
