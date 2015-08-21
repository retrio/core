package retrio.io;


class SyncedIO implements IEnvironment
{
	var base:IEnvironment;

	public function new(base:IEnvironment)
	{
		this.base = base;
	}

	// TODO: other methods
}
